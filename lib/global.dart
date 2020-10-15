import 'dart:io';
import 'dart:isolate';
import 'package:nexthour/model/todo.dart';
import 'package:nexthour/model/task_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

File jsonFile;
Directory dir;
String fileName = "userJSON.json";
bool fileExists = false;
Map<dynamic, dynamic> fileContent;


String name='';
String email='';
String mobile='';
String dob='';
String address='';
String role='';
String nameInitial='';
String message='';
String fullData='';
// ignore: non_constant_identifier_names
String created_at='';
String activePlan='';
String activeStatus='';
String expiryDate='';
String subscriptionHistory='';
String subNamesHistory='';
String ip = 'Unknown';
String dailyAmountAp;

var screenCount;
var status;
int movieDataLength;
int menuDataListLength;
bool boolValue;
SharedPreferences prefs;
DateTime currentDate;

//  For user profile, plan subscription details and payment history details.
var userId;
var dataUser;
var userDetail;
var userRole;
var userName;
var userEmail;
var userMobile;
var userDOB;
var userImage;
var userCreatedAt;
var userActivePlan;
var downloadLimit;
var mScreenCount;
var userPaypalHistory;
var userStripeHistory;
var userActiveStatus;
var userExpiryDate;
var userSubscriptionHistory;
var userSubNamesHistory;
var userPlanStart;
var userPlanEnd;
var userPaymentType;
var userPaypalPayId;
var stripeCustomerId;
var difference;
var faqApiData;
var userProfileApiData;
var dateDiff;
var remainingDays;
var newVideosTM;
var blogResponse;
var commentsCount;
var blogComments;
var subComments;
var subCommentsCount;

//  For slider, movies and tv series
var sliderResponseData;
var mainData;
var topMData;
var showPaymentGateway;
int menuList;
var menuId;
var newVideosList1;
var newVideosListG;
var episodesList;
var code;
var seasonEpisodeData;
var checkConnectionStatus;
var donationUrl;

var playerTitle;
//  For payment gateways stripe, braintree and paystack
var ser;
var stripePayment;
var stripeData;
var stripeKey;
var stripePass;
var paypalPayment;
var payuPayment;
var paytmPayment;
var paystackPayment;
var braintreePayment;
var btreePayment;
var braintreeClientNonce;
var payStackKey;
var menuDataResponse;
var showWatchlist;
var genreId;
var userWatchListOld;
var homeApiResponseData;
var loginImageData;
var loginConfigData;
var homeDataBlocks;
var faqHelp;
var iFrameURL;
var videoLink;
var iReadyUrl;
var vUrl360;
var vUrl480;
var vUrl720;
var vUrl1080;
var screenUsed1;
var screenUsed2;
var screenUsed3;
var screenUsed4;
var activeScreen;
var iFrameUrlLSD;
String localPath;
var nToken;
var downFileName;
var bankPayment;
var razorPayPaymentStatus;
var paytmPaymentStatus;
var razorPayKey;
var paytmKey;
var accountNo;
var branchName;
var bankAccountName;
var bankIFSCCode;
var bankName;
var wEmail;
var donationStatus;
var blogStatus;
var fbLoginStatus;
var videoCommentsStatus;
var isAdmin;
var paytmMerchantKey;
var dCount;
var download;
var dailyAmount;


Future<List<Todo>> future;

//  Used for movies, slider and genres
List movieData;
List genreData;
List mDataCount;
List sliderData;
List topMenuData;
List menuDataArray;

List allDataList= new List();
List<Todo> todos = List();
List screenList = [];

Database database;

List<TaskInfo> dTasks;
List<ItemHolder> dItems;
bool isLoading;
bool permissionReady;
String dLocalPath;


//  Used for search page
List searchIds = new List();
List searchIds2 = new List();



//  Used for watchlist page
List userWatchList = new List();

Color greenPrime = const Color.fromRGBO( 125, 183, 91, 1.0);
Color bluePrime = const Color.fromRGBO( 72, 163, 198, 1.0);
Color primaryColor= Colors.black;
Color primaryDarkColor= const Color.fromRGBO( 0, 0, 0, 1.0);
Color blackColor= const Color.fromRGBO( 0, 0, 0, 1.0);
Color cardColor= const Color.fromRGBO( 90, 90, 90, 1.0);
Color textColor= const Color.fromRGBO( 30, 30, 30, 1.0);
Color whiteColor= const Color.fromRGBO(255, 255, 255, 1.0);