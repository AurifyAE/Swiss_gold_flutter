const String baseUrl = 'https://api.aurify.ae/user';
const String adminId = '66e994239654078fd531dc2a';
const String loginUrl = '$baseUrl/login/$adminId';
const String newArrivalurl = '$baseUrl/new-arrival';
const String topRatedurl = '$baseUrl/top-rated';
const String bestSellerUrl = '$baseUrl/best-seller';
const String categoryUrl = '$baseUrl/main-categories/$adminId';
const String listProductFromCategoryUrl =
    '$baseUrl/view-all?page={index}&mainCategory={cId}';
const String listProductFromTagUrl =
    '$baseUrl/view-all?page={index}&tags={tag}';
const String getCartUrl = '$baseUrl/get-cart/{userId}';
const String addToCartUrl = '$baseUrl/cart/$adminId/{userId}/{pId}';
const String deleteFromCartUrl = '$baseUrl/cart/$adminId/{userId}/{pId}';
const String incrementQuantityUrl =
    '$baseUrl/cart/increment/$adminId/{userId}/{pId}';
const String decrementQuantityUrl =
    '$baseUrl/cart/decrement/$adminId/{userId}/{pId}';
const String getWishlistUrl = '$baseUrl/get-wishlist/{userId}';
const String deleteFromWishlistUrl =
    '$baseUrl/wishlist/$adminId/{userId}/{pId}';
const String addToWishlistUrl =
    '$baseUrl/wishlist/$adminId/{userId}/{pId}?action=add';
const String changePasswordUrl = '$baseUrl/forgot-password/{userId}';
const String getServerUrl = '$baseUrl/get-server';
const String getBannerUrl = '$baseUrl/get-banner/$adminId';
const String commoditiesUrl = '$baseUrl/get-commodities/$adminId';
const String companyProfileUrl = '$baseUrl//get-profile/$adminId';
