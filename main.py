from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
main_url = 'https://api-ubt.mukuru.com/taurus/v1/resources/pay-out-partners'

def  get_payout_partners():
    partners = []
    payload = {
        "country":"ZW",
        "page_size": 14
    }
    response = requests.get(main_url,params=payload)
    data = response.json()

    for i in data['items']:
        partners.append({"name":i['name'],"id": i['guid']})

    return partners
        

def get_payout_partner_loction(guid):

    payload = {
        "page_size":5
    }
    response = requests.get(f"{main_url}/{guid}/locations",params=payload)
    print(response.status_code)
    data = response.json()
    for loc in data['items']:
        print(loc['name'])
        print(loc['coordinates'])
        return {"name":loc['name'],"coords":loc['coordinates']}


@app.route('/search-location', methods=['GET'])
def search_location():
    query = request.args.get('query')
    # Make an API call to a geocoding service (e.g., Google Maps API)
    response = requests.get(f"https://maps.googleapis.com/maps/api/geocode/json?address={query}&key=YOUR_API_KEY")
    data = response.json()
    # Extract relevant information
    locations = []
    for result in data['results']:
        locations.append({
            "name": result['formatted_address'],
            "latitude": result['geometry']['location']['lat'],
            "longitude": result['geometry']['location']['lng']
        })
    return jsonify(locations)


@app.route('/search',methods=["GET"])
def get_nearby_location():
    part = get_payout_partners()
    locations = []
    print(part)
    for partner in part:
        location = get_payout_partner_loction(partner['id'])
        locations.append(location)

    return jsonify(locations)
        



if __name__ == '__main__':
    app.run(debug=True,port=5000)