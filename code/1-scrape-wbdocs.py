# This code scrapres the WB's operations portal to download project apprasial documents
# for agriculture project. It will only work on a computer with access to these
# World Bank intranet
#
# Libraries --------------------------------------------------------------------
import os, time, shutil, json, random,re

from bs4 import BeautifulSoup
import pandas as pd
import functions as fun

import selenium
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException, ElementClickInterceptedException, NoSuchElementException
import urllib.request

# Inputs ------------------------------------------------------------------------

# Load list of projects (downloaded from operations portal)
projects = pd.read_csv("data/ag-projects-codes.csv")

# Turn list of projects into a list
projects_list = projects['id'].to_list()

# Create a blank data frame to append data for each project
df = pd.DataFrame(columns = ["id", "url"])

xpath_grid = '//*[@id="template-e-right"]/div[2]/div[2]/a[1]' # Found using inspect on chrome
xpath_txt = '/html/body/div[1]/div[1]/div[5]/div[1]/div[2]/div[2]/div[1]/div/ul/li[2]/a' # Found using inspect on chrome

driver = fun.get_driver() # Find the webbrowser in the computer

# Scrape ----------------------------------------------------------------------

# Loop over all projects in the list
for project in projects_list:

    # Look for the project's PAD
    search = "http://documents.worldbank.org/curated/en/docsearch?query=" + project + "%20project%20appraisal%20document"

    # Check if the PAD is available
    anydocs = test_page(driver, search, xpath_grid, 5)

    # For available projects, try to download the PAD
    if anydocs:

    # Check if PAD is available
        # Go to grid view
        driver.find_element_by_xpath(xpath_grid).click()

        # Get table that contains link to PAD
        html_wbdocs = driver.page_source
        soup = BeautifulSoup(html_wbdocs, "html.parser")

        # Inside the table, get the link to the PAD
        docs_table = soup.find("table", attrs={"id": "n07v1-projects-list-table"})
        table_row = docs_table.find('td', text = "Project Appraisal Document")

    # If PAD exists, test if a txt is available
        if table_row is not None:
            link = table_row.findPrevious("a").findPrevious("a").get('href')
            linkworks = test_page(driver, link, xpath_txt, 7)

    # If a txt is available, download it and save in the data/ folder
            if linkworks:
                driver.find_element_by_xpath(xpath_txt).click()
                time.sleep(8)

                pad = driver.page_source
                soup = BeautifulSoup(pad, "html.parser").get_text()

                with open('data/pad/' + project + '.txt', 'w', encoding = 'utf-8') as f:
                    f.write(soup)
