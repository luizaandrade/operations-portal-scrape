import os, time, shutil, json, random,re

from selenium import webdriver
from selenium.common.exceptions import ElementClickInterceptedException, NoSuchElementException


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
