import 'package:swiss_gold/core/models/category_model.dart';
import 'package:swiss_gold/core/services/category_service.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/view_models/base_model.dart';

class CategoryViewModel extends BaseModel {
  CategoryModel? _categoryModel;
  CategoryModel? get categoryModel => _categoryModel;
  Future<void> getCategory() async {
    setState(ViewState.loading);
    _categoryModel = await CategoryService.showCategory();
    setState(ViewState.idle);

    notifyListeners();
  }
}
