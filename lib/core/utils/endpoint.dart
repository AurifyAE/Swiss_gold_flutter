const String baseUrl = 'https://api.aurify.ae/user';
const String adminId = '67586119baf55a80a8277f01';
const String loginUrl = '$baseUrl/login/$adminId';
const String listProductUrl =
    '$baseUrl/view-all/?page={index}/&adminId=$adminId';
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
const String companyProfileUrl = '$baseUrl/get-profile/$adminId';
const String fixPriceUrl = '$baseUrl/products/fix-prices';
const String bookingUrl = '$baseUrl/booking/$adminId/{userId}';
const String changePassUrl = '$baseUrl/forgot-password/$adminId';
const String getVideoBannerUrl = '$baseUrl/get-VideoBanner/$adminId';
const String confirmQuantityUrl = '$baseUrl/order_quantity_confirmation';
const String getOrderHistoryUrl = '$baseUrl/fetch-order/$adminId/{userId}';
const String getSpotRateUrl = '$baseUrl/get-spotrates/$adminId';
