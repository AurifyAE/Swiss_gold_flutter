import 'package:swiss_gold/core/models/admin_profile_model.dart';
import 'package:swiss_gold/core/services/profile_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class CompanyProfileViewModel extends BaseModel {
  CompanyProfileModel? _companyProfileModel;
  CompanyProfileModel? get companyProfileModel => _companyProfileModel;

  Future<void> fetchCompanyProfile() async {
    setState(ViewState.loading);
    _companyProfileModel = await ProfileService.fetcCompanyProfile();
    setState(ViewState.idle);
    notifyListeners();
  }
}
