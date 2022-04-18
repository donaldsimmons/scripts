# Web scraper used to search for specific Bay District job postings

import sys
import argparse
from requests_html import HTMLSession

def main():
  args = setup_parser()
  query_data = setup_query(args)
  found_data = scrape_data(query_data)
  display_results(query_data["location"], found_data)

# Require script to accept URL, location and job search phrases
def setup_parser():
  parser = argparse.ArgumentParser()
  # Set URL through args as small step against misuse
  parser.add_argument("url", help="Sets URL to query for data")
  parser.add_argument("location", help="Sets phrase used to filter search by location/facility")
  parser.add_argument( "job_title", help="Sets phrase used to search for specific positions")
  args = parser.parse_args()
  return args

# Create dictionary to store required info for data scraping
def setup_query(args):
  query_info = {
    "url": args.url,
    "licensed_app_type": "00000001",
    "company_id": "00009961",
    "location": args.location,
    "job_title": args.job_title
  }
  return query_info

# Scrape data from given URL for location and job search settings
def scrape_data(query_opts):
  session = HTMLSession()
  params_opts = {
    "APPLICANT_TYPE_ID": query_opts["licensed_app_type"],
    "COMPANY_ID": query_opts["company_id"]
  }

  try:
    page = session.get(query_opts["url"], params=params_opts)
  except Exception as e:
    error_msg= "An error occurred when connecting to the given URL:"
    print("\n{0}\n{1}\n{2}\n".format(error_msg,"-"*60,e))
    sys.exit(1)

  rows = page.html.find('tr', containing=query_opts["location"]);
  jobs = [row.find('td', containing=query_opts["job_title"]) for row in rows if row]

  # Remove empty results returned from scraping
  return list(filter(None, jobs))

# Display results or 'no results' responses
def display_results(location, result_data):
  if result_data:
    jobs = [job[0].text for job in result_data]
    print("{0}\n{1}\n{0}\n".format("-"*50, location))
    print("\n".join(jobs))
    print("-"*50)
  else:
    print("There are no postings for " + location)

if __name__ == "__main__":
  main()
