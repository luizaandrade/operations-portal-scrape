import os, time, shutil, json, random,re

from selenium import webdriver
from selenium.common.exceptions import ElementClickInterceptedException, NoSuchElementException
from bs4 import BeautifulSoup
import pandas as pd

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException

#Set up the selenium driver
def get_driver():
    # these settings are all from https://stackoverflow.com/questions/56897041/how-to-save-opened-page-as-pdf-in-selenium-python
    chrome_options = webdriver.ChromeOptions()
    settings = {
        "recentDestinations": [{"id": "Save as PDF","origin": "local","account": "",}],
        "selectedDestinationId": "Save as PDF",
        "version": 2
        }
    prefs = {'printing.print_preview_sticky_settings.appState': json.dumps(settings)}
    chrome_options.add_experimental_option('prefs', prefs)
    chrome_options.add_argument('--kiosk-printing')
    CHROMEDRIVER_PATH = 'C:/WBG/chromedriver/chromedriver.exe'

    # Set up selenium driver
    return webdriver.Chrome(chrome_options=chrome_options, executable_path=CHROMEDRIVER_PATH)

# Get project 'Key Documents' page in operations portal

def page_html(driver, url, xpath):

    driver.get(url)
    timeout = 3
    try:
        element_present = EC.presence_of_element_located((By.XPATH, xpath))
        WebDriverWait(driver, timeout).until(element_present)
        print("Page is ready!")
    except TimeoutException:
        print("Page does not contain xpath element")
        return "stop"

    return driver.page_source

def pad_link(html):

    soup = BeautifulSoup(html, "html.parser")
    docs_table = soup.find("table", attrs={"id": "WB-docs-table"})
    table_row = docs_table.find('td', text = "Project Appraisal Document")
    
    if table_row is None:
        print("PAD is not listed as one of project's documents")
        return "stop"
    else:
    link = table_row.findPrevious("a")
    return link.get('href')


def txt_link(html):
    
    soup = BeautifulSoup(html, "html.parser")
    txt_link = soup.find(id = "lnkTxtFile")
    
    return txt_link.get('href')
    
def df_row(project, url):

    result = {"id": project, "url": url}
    result_df = pd.DataFrame.from_dict(result, orient = "index")
    
    return result_df.T

    