const appName = "Discover Destination";

const mOneSignalAppId = 'ADD_YOUR_ONE_SIGNAL_APP_ID';
const mOneSignalRestKey = 'ADD_YOUR_ONE_SIGNAL_REST_KEY';

const googleMapApiKey = 'AIzaSyDTn7Lh3Whn41PpxdeHADcFdIXGoMFmxGk';

/// storage bucket
const mStorageBucket = 'discover-destination.appspot.com';

/// Storage Folder
const mFirebaseStorageFilePath = 'images';
const mPlacesStoragePath = 'PlaceImages';
const mCategoryStoragePath = 'categoryImages';
const mStateStoragePath = 'stateImages';
const mProfileStoragePath = 'userProfile';

int perPageLimit = 10;
int latestRecordLimit = 3;

const PlaceTypeMostRated = "PlaceTypeMostRated";
const PlaceTypeMostFavourite = "PlaceTypeMostFavourite";

const ThemeModeLight = 0;
const ThemeModeDark = 1;

const DASHBOARD_INDEX = 0;
const CATEGORY_INDEX = 1;
const STATE_INDEX = 2;
const CITY_INDEX = 3;
const PLACES_REQUEST_INDEX = 4;
const PLACE_INDEX = 5;
const UPLOAD_PLACE_INDEX = 6;
const HOTEL_INDEX = 7;
const UPLOAD_HOTEL_INDEX = 8;
const USER_INDEX = 9;
const PLACE_REVIEW_INDEX = 10;
const APP_SETTING_INDEX = 11;

const IS_LOGGED_IN = 'IS_LOGGED_IN';
const USER_ID = 'USER_ID';
const USER_NAME = 'USER_NAME';
const USER_EMAIL = 'USER_EMAIL';
const USER_PASSWORD = 'USER_PASSWORD';
const USER_CONTACT_NO = 'USER_CONTACT_NO';
const USER_PROFILE = 'USER_PROFILE';
const LOGIN_TYPE = 'LOGIN_TYPE';
const IS_ADMIN = 'IS_ADMIN';
const IS_DEMO_ADMIN = 'IS_DEMO_ADMIN';
const IS_NOTIFICATION_ON = "IS_NOTIFICATION_ON";
const FCM_TOKEN = 'FCM_TOKEN';

/* Login Type */
const LoginTypeApp = 'app';
const LoginTypeGoogle = 'google';
const LoginTypeOTP = 'otp';
const LoginTypeApple = 'apple';

/// Ads type
String isGoogleAds = "admob";
String isFacebookAds = "facebook";

bool defaultIsAdsEnable = true;
bool defaultIsNotificationOn = true;
String defaultAdsType = isFacebookAds;

