# Import libraries

import time, datetime, socket, hashlib
from bs4 import BeautifulSoup
import utils as scrape_utils
import requests
import urllib
import pandas as pd

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException

projects = pd.read_csv("data/ag-projects-codes.csv") 
projects_list = projects['id'].to_list()
projects_list = projects_list[0:3]

driver = scrape_utils.get_driver()

for project in projects_list :
    site = "http://operationsportal.worldbank.org/secure/" + project + "/home?tab=documents#IB"
    print(site)

    # Get project 'Key Documents' page in operations portal
    driver.get(site)
    timeout = 3
    try:
        element_present = EC.presence_of_element_located((By.XPATH, '/html/body/div[1]/div[3]/div/div/div[1]/div[1]/div/div[2]/div/div/div/div[2]/div[3]/div[1]/div[5]/div/div[4]/table'))
        WebDriverWait(driver, timeout).until(element_present)
        print("Page is ready!")
    except TimeoutException:
        print("Timed out waiting for page to load")

    html_keydocs = driver.page_source

    # Extract link to PAD from 'Key Documents'page HTML
    soup = BeautifulSoup(html_keydocs, "html.parser")
    docs_table = soup.find("table", attrs={"id": "WB-docs-table"})
    table_row = docs_table.find('td', text = "Project Appraisal Document")
    link = table_row.findPrevious("a")
    url_pad = link.get('href')

    # Get PAD page HTML
    driver.get(url_pad)
    timeout = 5
    try:
        element_present = EC.presence_of_element_located((By.XPATH, '/html/body/form/div[6]/div/div/div/div/span/div[1]/div/div/div[1]/div[1]/div/div[1]/div/div[1]/div[4]/div/div[1]/div[1]/div/div[1]/div/p[1]/a[3]'))
        WebDriverWait(driver, timeout).until(element_present)
        print("Page is ready!")
    except TimeoutException:
        print("Timed out waiting for page to load")

    html_pad = driver.page_source

    # Extract link to PAD from 'Key Documents'page HTML
    soup = BeautifulSoup(html_pad, "html.parser")
    txt_link = soup.find(id = "lnkTxtFile")
    url = txt_link.get('href')

    # Return the url
    print(url_txt)



    