# Operations portal scraping

This repository contains code to scrape and analyze project documentation from agriculture-relation lending operations at the World Bank. This information is used to inform
DIME's agriculture team on areas that are relevant for research meant to inform project design.

The code is divided in three components:

### Scraping
This part of the code uses Python, since it requires scraping dynamic websites. We start from a list of agriculture-related projects extracted from the WB 
operations portal, and extract the Project Appraisal Document from the World Bank documents repository. To run this code, access to the World Bank intranet is required. The custom functions used for this code are defined in `code/functions.py`
- Input: `data/ag-projects-codes.csv`, adapted from the file downloaded from the WB Operations Portal (`data/operations-portal-search.xls`)
- Outputs: 401 Project Appraisal Documents saved in txt format, stored in `data/pad`. These documents are not included in the repository, as they are not for public use.
- Run time: more than 2 hours, last I checked

### Processing
This part of the code uses R, as this language is better suited for data wrangling. We create custom datasets based on the scraped data to reflect the
information of interest for the analysis.
- Input: `ag-projects.csv`, downloaded from the Operations Portal, and the corresponding PADs in txt files, saved with names `Pprojectcode.txt` in folder `data/pad`.
These documents are not included in the repository, as they are not for public use.
- Ouputs: the files saved in folder `data/processed`, that is, `ag-projects-constructed.RDS`, `ag-projects-region-summary.RDS`, `ag-projects-summary.RDS`, 
`ag-projects-value-summary.RDS`, `ag-projects-year-summary.RDS`, `pads.RDS`
- Run time: ~5 min

### Analysis
An R Markdown script that creates a PDF file with the analysis developed with the research team.
- Input: the files saved in folder `data/processed`, that is, `ag-projects-constructed.RDS`, `ag-projects-region-summary.RDS`, `ag-projects-summary.RDS`, 
`ag-projects-value-summary.RDS`, `ag-projects-year-summary.RDS`,
- Output: `Agricultural Projects - Project Appraisal Documents Descriptives.pdf`
- Run time: ~1 min
