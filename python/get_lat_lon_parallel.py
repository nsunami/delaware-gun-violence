# dependencies
import aiohttp
import asyncio
import json
import geocoder
import time
from requests import HTTPError
################# Parallelizing Bureau of Census API fetch BEGIN #################



def extract_fields_from_Census_Bureau_response(response_data, input_address):
    """
    Function Description: This function extract information from Census Bureau API response
    :param response:  server response
    :return:  dict { 'matched address','lat', 'lon'}
    :Author: Mohammad Baksh
    """
    response_data_res = response_data['result']
    response_address_match = response_data_res['addressMatches']
    if len(response_address_match) > 0:
        response_address_match_address = response_address_match[0]['matchedAddress']
        response_address_match_coordinate = response_address_match[0]['coordinates']
        output = {'input_address': input_address, 'matched_address': response_address_match_address,
                  'lat': response_address_match_coordinate['y'], 'lon': response_address_match_coordinate['x']}
        return output
    else:
        output = {'input_address': input_address, 'matched_address': "Unable To Geolocate The Address"}
        return output


async def get_responce_detielas(address, session):
    url = "https://geocoding.geo.census.gov/geocoder/locations/onelineaddress"

    querystring = {"format": "json", "address": address, "benchmark": "Public_AR_Current",
                   "vintage": "Current_Current"}
    headers = {}
    # response = requests.request("GET", url, headers=headers, params=querystring)

    try:
        response = await session.request(method='GET', url=url, headers=headers, params=querystring, ssl=False)
        response.raise_for_status()
    except HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
    except Exception as err:
        print(f"An error ocurred: {err}")
    response_json = await response.json()
    return response_json


async def run_program(address, session, out):
    """Wrapper for running program in an asynchronous manner"""

    response = await get_responce_detielas(address, session)
    parsed_response = extract_fields_from_Census_Bureau_response(response, address)
    return out.append(parsed_response)


async def lat_long_from_Census_Bureau_parallel(addre, out):
    conn = aiohttp.TCPConnector()
    async with aiohttp.ClientSession(connector=conn) as session:
        await asyncio.gather(*[run_program(addresses_list, session, out) for addresses_list in addre])


################# Parallelizing Bureau of Census API fetch END #################

################# Initializing  ArcGIS API BEGIN #################
def geocoding_using_geocoder_lib(address):
    """
    Function Description: This function uses the geocoder library to geocoded addresses
                            https://github.com/DenisCarriere/geocoder
                            using ArcGIS service limit at 19999 request daily
                            ArcGIS latency of the response is 86ms per request
    :param address:  string address
    :return:  dict {'input input_address', 'matched address','lat', 'lon'}
    :Author: Mohammad Baksh
    """
    g = geocoder.arcgis(address)
    service_response = g.json

    # added the Delaware condition to avoid wrong parsing
    if (service_response is not None) and ('Delaware' in service_response['raw']['name']):
        matched_address = service_response['raw']['name']
        latitude = service_response['lat']
        longitude = service_response['lng']
        output = {'input_address': address, 'matched_address': matched_address, 'lat': latitude, 'lon': longitude}
        return output
    else:
        output = {'input_address': address, 'matched_address': "Unable To Geolocate The Address"}
        return output


################# Initializing  ArcGIS API END #################


################# Running the whole process  BEGIN #################
def get_lat_long_coordinates(list_addresses):
    """
    Run the whole thing
    :param list_addresses:
    :return:
    """
    output_from_api_1 = []
    loop = asyncio.get_event_loop()
    loop.run_until_complete(lat_long_from_Census_Bureau_parallel(list_addresses, output_from_api_1))
    output_from_api_2 = []
    for i in range(len(output_from_api_1)):
        if output_from_api_1[i]['matched_address'] == "Unable To Geolocate The Address":
            output_from_api_2.append(geocoding_using_geocoder_lib(str(output_from_api_1[i]['input_address'])))
        else:
            output_from_api_2.append(output_from_api_1[i])
    # with open("output_addresses_geocoded.json", "w") as outfile:
    #     json.dump(output_from_api_2, outfile)
    return output_from_api_2


################# Running the whole process  END #################


################# TEST BEGIN #################

# start_time = time.time()
# get_lat_long_coordinates(add)
# print("--- %s seconds ---" % (time.time() - start_time))

################# TEST END #################
