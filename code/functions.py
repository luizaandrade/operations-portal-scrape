import os, time, shutil, json, random,re

from bs4 import BeautifulSoup
import pandas as pd

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException, NoSuchElementException

#Set up the selenium driver ---------------------------------------------------------------
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
# Check if 'Key Documents' page exists in operations portal --------------------------------------
def test_page(driver, url, xpath, timeout):

    driver.get(url)

    try:
        element_present = EC.presence_of_element_located((By.XPATH, xpath))
        WebDriverWait(driver, timeout).until(element_present)
    except TimeoutException:
        return False

    return True

# Extract the link to the PAD from the project page ---------------------------------------------
def pad_link(html):

    soup = BeautifulSoup(html, "html.parser")
    docs_table = soup.find("table", attrs={"id": "WB-docs-table"})
    table_row = docs_table.find('td', text = "Project Appraisal Document")

    if table_row is None:
        return "stop"
    else:
        link = table_row.findPrevious("a")
        return link.get('href')


# Exctract the link to the txt version of the PAD ------------------------------------------------
def txt_link(html):

    soup = BeautifulSoup(html, "html.parser")
    txt_link = soup.find(id = "lnkTxtFile")

    return txt_link.get('href')

# Append project information to the data frame --------------------------------------------------
def df_row(project, url):

    result = {"id": project, "url": url}
    result_df = pd.DataFrame.from_dict(result, orient = "index")

    return result_df.T
