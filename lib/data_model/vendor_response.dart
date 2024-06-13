class Vendor {
  VendorDetails? user;

  Vendor({this.user});

  Vendor.fromJson(Map<String, dynamic> json) {
    user =
        json['user'] != null ? new VendorDetails.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class VendorDetails {
  int? id;
  String? username;
  String? slug;
  String? email;
  String? emailStatus;
  String? token;
  String? roleId;
  String? balance;
  String? numberOfSales;
  String? userType;
  String? avatar;
  String? coverImage;
  String? coverImageType;
  String? banned;
  String? firstName;
  String? lastName;
  String? aboutMe;
  String? phoneNumber;
  String? countryId;
  String? stateId;
  String? cityId;
  String? address;
  String? zipCode;
  String? showEmail;
  String? showPhone;
  String? showLocation;
  String? personalWebsiteUrl;
  String? facebookUrl;
  String? twitterUrl;
  String? instagramUrl;
  String? pinterestUrl;
  String? linkedinUrl;
  String? vkUrl;
  String? youtubeUrl;
  String? whatsappUrl;
  String? telegramUrl;
  String? lastSeen;
  String? showRssFeeds;
  String? isActiveShopRequest;
  String? isMembershipPlanExpired;
  String? isUsedFreePlan;
  String? cashOnDelivery;
  String? isFixedVat;
  String? fixedVatRate;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  VendorDetails(
      {this.id,
      this.username,
      this.slug,
      this.email,
      this.emailStatus,
      this.token,
      this.roleId,
      this.balance,
      this.numberOfSales,
      this.userType,
      this.avatar,
      this.coverImage,
      this.coverImageType,
      this.banned,
      this.firstName,
      this.lastName,
      this.aboutMe,
      this.phoneNumber,
      this.countryId,
      this.stateId,
      this.cityId,
      this.address,
      this.zipCode,
      this.showEmail,
      this.showPhone,
      this.showLocation,
      this.personalWebsiteUrl,
      this.facebookUrl,
      this.twitterUrl,
      this.instagramUrl,
      this.pinterestUrl,
      this.linkedinUrl,
      this.vkUrl,
      this.youtubeUrl,
      this.whatsappUrl,
      this.telegramUrl,
      this.lastSeen,
      this.showRssFeeds,
      this.isActiveShopRequest,
      this.isMembershipPlanExpired,
      this.isUsedFreePlan,
      this.cashOnDelivery,
      this.isFixedVat,
      this.fixedVatRate,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  VendorDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    slug = json['slug'];
    email = json['email'];
    emailStatus = json['email_status'];
    token = json['token'];
    roleId = json['role_id'];
    balance = json['balance'];
    numberOfSales = json['number_of_sales'];
    userType = json['user_type'];
    avatar = json['avatar'];
    coverImage = json['cover_image'];
    coverImageType = json['cover_image_type'];
    banned = json['banned'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    aboutMe = json['about_me'];
    phoneNumber = json['phone_number'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    address = json['address'];
    zipCode = json['zip_code'];
    showEmail = json['show_email'];
    showPhone = json['show_phone'];
    showLocation = json['show_location'];
    personalWebsiteUrl = json['personal_website_url'];
    facebookUrl = json['facebook_url'];
    twitterUrl = json['twitter_url'];
    instagramUrl = json['instagram_url'];
    pinterestUrl = json['pinterest_url'];
    linkedinUrl = json['linkedin_url'];
    vkUrl = json['vk_url'];
    youtubeUrl = json['youtube_url'];
    whatsappUrl = json['whatsapp_url'];
    telegramUrl = json['telegram_url'];
    lastSeen = json['last_seen'];
    showRssFeeds = json['show_rss_feeds'];
    isActiveShopRequest = json['is_active_shop_request'];
    isMembershipPlanExpired = json['is_membership_plan_expired'];
    isUsedFreePlan = json['is_used_free_plan'];
    cashOnDelivery = json['cash_on_delivery'];
    isFixedVat = json['is_fixed_vat'];
    fixedVatRate = json['fixed_vat_rate'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['slug'] = this.slug;
    data['email'] = this.email;
    data['email_status'] = this.emailStatus;
    data['token'] = this.token;
    data['role_id'] = this.roleId;
    data['balance'] = this.balance;
    data['number_of_sales'] = this.numberOfSales;
    data['user_type'] = this.userType;
    data['avatar'] = this.avatar;
    data['cover_image'] = this.coverImage;
    data['cover_image_type'] = this.coverImageType;
    data['banned'] = this.banned;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['about_me'] = this.aboutMe;
    data['phone_number'] = this.phoneNumber;
    data['country_id'] = this.countryId;
    data['state_id'] = this.stateId;
    data['city_id'] = this.cityId;
    data['address'] = this.address;
    data['zip_code'] = this.zipCode;
    data['show_email'] = this.showEmail;
    data['show_phone'] = this.showPhone;
    data['show_location'] = this.showLocation;
    data['personal_website_url'] = this.personalWebsiteUrl;
    data['facebook_url'] = this.facebookUrl;
    data['twitter_url'] = this.twitterUrl;
    data['instagram_url'] = this.instagramUrl;
    data['pinterest_url'] = this.pinterestUrl;
    data['linkedin_url'] = this.linkedinUrl;
    data['vk_url'] = this.vkUrl;
    data['youtube_url'] = this.youtubeUrl;
    data['whatsapp_url'] = this.whatsappUrl;
    data['telegram_url'] = this.telegramUrl;
    data['last_seen'] = this.lastSeen;
    data['show_rss_feeds'] = this.showRssFeeds;
    data['is_active_shop_request'] = this.isActiveShopRequest;
    data['is_membership_plan_expired'] = this.isMembershipPlanExpired;
    data['is_used_free_plan'] = this.isUsedFreePlan;
    data['cash_on_delivery'] = this.cashOnDelivery;
    data['is_fixed_vat'] = this.isFixedVat;
    data['fixed_vat_rate'] = this.fixedVatRate;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
