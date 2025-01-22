from selenium import webdriver
from selenium.webdriver.common.by import By
import json
import boto3
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


def get_data():
    # get animepahe.ru
    url = "https://animepahe.com/api?m=airing&page=1"
    options = webdriver.ChromeOptions()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    driver = webdriver.Chrome(options=options)
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
        response = s3.get_object(Bucket='anime-notify', Key='last_anime')
        anime = response['Body'].read().decode('utf-8')
    except:
        anime = None
    return anime


def write_last_sent_anime(anime):
    # using s3 bucket write the last anime sent
    try:
        s3 = boto3.client('s3')
        s3.put_object(Bucket='anime-notify', Key='last_anime', Body=anime)
    except:
        print('Error writing to s3')


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
    pass


def handler():
    data = get_data()
    if data:
        last_anime = get_last_sent_anime()
        new_anime = get_new_anime(data, last_anime)
        messages = build_messages(new_anime)
        send_messages(messages)
        write_last_sent_anime(new_anime)
