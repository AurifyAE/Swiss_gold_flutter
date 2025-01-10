import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:swiss_gold/core/models/admin_profile_model.dart';
import 'package:swiss_gold/core/services/secrete_key.dart';
import 'package:swiss_gold/core/utils/endpoint.dart';


class ProfileService {
  static final client = http.Client();

  static Future<CompanyProfileModel?> fetcCompanyProfile() async {
    try {
      var response = await client.get(
        Uri.parse(companyProfileUrl),
        headers: {
          'X-Secret-Key': secreteKey,
          'Content-Type': 'application/json'
        }, // Encoding payload to JSON
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        return CompanyProfileModel.fromJson(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }



}