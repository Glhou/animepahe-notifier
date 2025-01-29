from selenium import webdriver
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
import json
import boto3
import os
import urllib3
'''
Data format:
{
    id: int,
    anime_id: int,
    anime_title: str,
    episode: int,
    episode2: bool,
    edition: str,
    fansub: str,
    snapshot: str(url),
    disc: str,
    session: str(id),
    filler: bool,
    created_at: str(date),
    completed: bool
}
'''

# Set the download location for ChromeDriver to /tmp
os.environ["WDM_LOCAL"] = "/tmp"


def get_data():
    # get animepahe.ru
    url = "https://animepahe.com/api?m=airing&page=1"
    chrome_options = webdriver.ChromeOptions()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--headless")  # If you need headless mode
    chrome_options.binary_location = "/opt/chrome/chrome-linux64/chrome"
    # check if the binary exists
    if not os.path.exists(chrome_options.binary_location):
        raise FileNotFoundError(f"Chrome binary not found at {chrome_options.binary_location}")
    #chrome_driver_path = ChromeDriverManager().install()

    service = Service("/opt/chrome-driver/chromedriver-linux64/chromedriver", log_path="/tmp/chromedriver.log")

    driver = webdriver.Chrome(
        service=service,
        options=chrome_options
    )

    driver.get(url)
    while driver.title == "DDoS-Guard":
        driver.implicitly_wait(1)
    data = driver.find_element(By.TAG_NAME, 'pre').text
    data = json.loads(data)
    driver.quit()
    return data["data"]


def get_last_sent_anime():
    # using s3 bucket get the last anime sent
    try:
        s3 = boto3.client('s3')
        response = s3.get_object(Bucket='anime-notify-bucket', Key='last_anime')
        anime = response['Body'].read().decode('utf-8')
    except:
        anime = None
    return anime


def write_last_sent_anime(anime):
    # using s3 bucket write the last anime sent
    try:
        s3 = boto3.client('s3')
        if anime:
            s3.put_object(Bucket='anime-notify-bucket', Key='last_anime', Body=json.dumps(anime[0]))
    except Exception as e:
        print(f'Error writing to s3 : {e}')


def get_new_anime(data, last_anime):
    for anime in data:
        if 'BD' in anime['disc']:
            data.remove(anime)
    if last_anime:
        for anime in data:
            if anime['anime_title'] == last_anime:
                data = data[:data.index(anime)]
                break
    return data


def build_messages(data):
    messages = []
    for anime in data:
        message = f"New episode of {anime['anime_title']} is out!\nEpisode: {anime['episode']}\nSnapshot: {anime['snapshot']}\nCreated at: {anime['created_at']}\nCompleted: {anime['completed']}\n"
        messages.append(message)
    return messages


def send_messages(messages):
    try:
        ecs_service_dns_name = os.environ.get("ECS_SERVICE_DNS_NAME")
        url = f"http://{ecs_service_dns_name}/send"
        body = {"service": "animepahe-notifier", "level": "INFO", "message": "\n".join(messages)}
        headers = {"Content-Type": "application/json"}
        response = urllib3.PoolManager().request("POST", url, body=json.dumps(body), headers=headers)
        if response.read() == "Error: missing evironment variables":
            raise Exception("Error: missing evironment variables")
        print(response.status)
        print(response.data)
        print(response.json())
        print(response.read())
    except Exception as e:
        print(f"Error sending messages: {e}")


def handler(event, context):
    try:
        data = get_data()
        if data:
            last_anime = get_last_sent_anime()
            new_anime = get_new_anime(data, last_anime)
            messages = build_messages(new_anime)
            send_messages(messages)
            write_last_sent_anime(new_anime)
            print("Function executed successfully")
            print(new_anime)
            return {"status": "success", "message": "Function executed successfully", "new_anime": new_anime}
        return {"status": "Error", "message": "There were no data"}
    except Exception as e:
        print(e)
        return {"status": "Error", "message": str(e)}