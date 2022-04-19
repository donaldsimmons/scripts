# Web scraper used to search for specific Bay District job postings

import sys
import argparse
from requests_html import AsyncHTMLSession

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
    "support_app_type": "00000002",
    "company_id": "00009961",
    "location": args.location,
    "job_title": args.job_title
  }
  return query_info

# Scrape data from given URL for location and job search settings
def scrape_data(query_opts):
  session = AsyncHTMLSession()

  # Create dicts for storing page-specific params
  param_opts_sets = set_params([query_opts["licensed_app_type"], query_opts["support_app_type"]])

  # Call async functions that return 'awaitables' for use w/ 'asyncio.run'
  # 'asyncio.run' only takes 'callables': Lams used to invoke funcs w/ args
  page_lambdas = [lambda: page(session, query_opts["url"], param_opts) for param_opts in param_opts_sets]
  # Expand lambda list to run all query for all pages
  results = session.run(*page_lambdas)

  # Drill through response arrays to build dicts w/ job name and type
  rows = [r.html.find('tr', containing=query_opts["location"]) for r in results]
  jobs = []
  for r in rows:
    for table_row in r:
      job_type = table_row.find('.rsbuttons + .rsbuttons + td')
      job_name = table_row.find('td', containing=query_opts["job_title"])
      if job_type and job_name:
        jobs.append({"job_type": job_type[0].text, "job_name": job_name[0].text})
  return jobs

# Create dicts dynamically to use as query params
def set_params(app_types):
  params_dicts = [{"APPLICATION_TYPE_ID": app_type, "COMPANY_ID": "00009961"} for app_type in app_types]
  return params_dicts

# Set up async functions for use when scraping w/ async.io
async def page(session, url, params):
  param_string = "&".join([key + "=" + value for key, value in params.items()])
  full_url = url + "?" + param_string

  try:
    result = await session.get(full_url)
  except Exception as e:
    error_msg= "An error occurred when connecting to the given URL:"
    print("\n{0}\n{1}\n{2}\n".format(error_msg,"-"*60,e))
    sys.exit(1)
  return result

# Display results or 'no results' responses
def display_results(location, result_data):
  if result_data:
    print("{:<78}\n|{:^78}|\n{:>78}\n".format("-"*80, location, "-"*80))
    for job in result_data:
      print("|{:<10}| {:<66}|\n".format(format_job_type(job["job_type"]), job["job_name"]))
    print("-"*80)
  else:
    print("There are no postings for " + location)

def format_job_type(job_type):
  if "Certified" in job_type or "Licensed" in job_type:
    return "Licensed"
  else:
    return job_type

if __name__ == "__main__":
  main()
