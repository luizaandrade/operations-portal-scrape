# Import libraries ---------------------------------------

import time, datetime, socket, hashlib
import functions as fun
import pandas as pd

# Inputs  ----------------------------------------------

# List of all ag projects in the operations portal
projects = pd.read_csv("data/ag-projects-codes.csv") 

# xpath to the table in the project's page that contains the link to PAD
xpath_table = '/html/body/div[1]/div[3]/div/div/div[1]/div[1]/div/div[2]/div/div/div/div[2]/div[3]/div[1]/div[5]/div/div[4]/table'

# xpath to the link to txt version of PAD in the PAD document page
xpath_txt = '/html/body/form/div[6]/div/div/div/div/span/div[1]/div/div/div[1]/div[1]/div/div[1]/div/div[1]/div[4]/div/div[1]/div[1]/div/div[1]/div/p[1]/a[3]'

# Initial settings ------------------------------------

# Open browser window
driver = fun.get_driver()

# Turn list of projects into a list
projects_list = projects['id'].to_list()

# Create a blank data frame to append data for each project
df = pd.DataFrame(columns = ["id", "url"])

# Now loop over projects and save the link to the PAD in txt format
for project in projects_list :

    # Project's page on the intranet
    url_project = "http://operationsportal.worldbank.org/secure/" + project + "/home?tab=documents#IB"
    
    # Get project 'Key Documents' page in operations portal
    html_keydocs = fun.page_html(driver, url_project, xpath_table)

    # If there is are any files in key documents, go ahead
    if html_keydocs != 'stop':
        print(project + ": HTML extracted for key docs")
        # Extract link to PAD from 'Key Documents'page HTML
        url_pad = fun.pad_link(html_keydocs)

        # Check that link is valid (i.e., PAD is available)
        if url_pad == 'stop':
            # Create new row to the data frame saying there's no PAD
            result_row = fun.df_row(project, 'PAD not found in key documents')
        else:
            print(project + ": PAD link found")

            # Get PAD page for project
            html_pad = fun.page_html(driver, url_pad, xpath_txt)

            if html_pad != 'stop':
                print(project + ": HTML extracted for PAD page")

                # Extract link to PAD from 'Key Documents'page HTML
                url_txt = fun.txt_link(html_pad)

                # Create new row to the data frame with the information collected
                result_row = fun.df_row(project, url_txt)
            else:
                # Create new row to the data frame saying there's no PAD
                result_row = fun.df_row(project, 'PAD txt not found')
    else:
        result_row = fun.df_row(project, 'no key docs found')

    # Append row to data frame
    df = df.append(result_row)

driver.close()
df.to_csv ('data/ag-projects-pad-links.csv', index = False, header = True)


