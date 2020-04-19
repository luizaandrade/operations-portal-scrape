
import time, datetime, socket, hashlib
from bs4 import BeautifulSoup
import utils as scrape_utils
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException

driver = scrape_utils.get_driver()
site = "http://operationsportal.worldbank.org/secure/P169758/home?tab=documents#IB"
driver.get(site)
timeout = 5
try:
    element_present = EC.presence_of_element_located((By.XPATH, '/html/body/div[1]/div[3]/div/div/div[1]/div[1]/div/div[2]/div/div/div/div[2]/div[3]/div[1]/div[5]/div/div[4]/table'))
    WebDriverWait(driver, timeout).until(element_present)
    print("Page is ready!")
except TimeoutException:
    print("Timed out waiting for page to load")

html = driver.page_source
driver.close()
soup = BeautifulSoup(html, "html.parser")
docs_table = soup.find("table", attrs={"id": "WB-docs-table"})
table_row = docs_table.find('td', text = "Project Appraisal Document")
link = table_row.findPrevious("a")
url = link.get('href')

file.close() 

