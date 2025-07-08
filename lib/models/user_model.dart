class UserModel {
  int? id;
  String? name, username, email, phone, website;
  Address? address;
  Company? company;

  UserModel({this.id, this.name, this.username, this.email, this.phone,
    this.website, this.address, this.company});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? '';
    username = json['username'] ?? '';
    email = json['email'] ?? '';
    phone = json['phone'] ?? '';
    website = json['website'] ?? '';
    try {
      address = Address.fromJson(json['address']);
    } catch(_) {}
    try {
      company = Company.fromJson(json['company']);
    } catch(_) {}
  }

}

class Address {
  String? street, suite, city, zipcode;
  Geo? geo;

  Address({this.street, this.suite, this.city, this.zipcode, this.geo});

  Address.fromJson(Map<String, dynamic> json) {
    street = json['street'] ?? '';
    suite = json['suite'] ?? '';
    city = json['city'] ?? '';
    zipcode = json['zipcode'] ?? '';
    try {
      geo = Geo.fromJson(json['geo']);
    } catch(_) {}
  }
}

class Geo {
  String? lat, lng;

  Geo({this.lat, this.lng});

  Geo.fromJson(Map<String, dynamic> json) {
    lat = json['lat'] ?? '';
    lng = json['lng'] ?? '';
  }
}

class Company {
  String? name, catchPhrase, bs;

  Company({this.name, this.catchPhrase, this.bs});

  Company.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    catchPhrase = json['catchPhrase'] ?? '';
    bs = json['bs'] ?? '';
  }
}