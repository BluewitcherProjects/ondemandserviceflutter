import 'package:demandium/feature/auth/widgets/existing_account_bottom_sheet.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class SocialLoginButton extends StatelessWidget {
  final String? title;
  final String ? fromPage;
  final SocialLoginType socialLoginType;
  final bool showPadding;
  const SocialLoginButton({super.key, this.title, required this.socialLoginType, required this.fromPage, required this.showPadding});

  @override
  Widget build(BuildContext context) {
    return  Padding( padding:  EdgeInsets.only(
      right : showPadding && Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeDefault : 2,
      left : showPadding && !Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeDefault : 2 ,
    ),
      child: InkWell(
        onTap: ()=> _onTap(socialLoginType: socialLoginType, fromPage: fromPage),
        child: TextHover(
          builder: (hovered){
            return  Container(
              height: title !=null ? 47 : 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: hovered ? 0.5 : 0.2),
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Padding(padding: EdgeInsets.symmetric(
                      horizontal: title?.trim() == "" ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeEight ,
                  ),
                    child: Image.asset(
                      socialLoginType == SocialLoginType.google ? Images.google :
                      socialLoginType == SocialLoginType.facebook ? Images.facebook : Images.apple,
                      height: ResponsiveHelper.isDesktop(context) ? 25 :ResponsiveHelper.isTab(context) ? 25 :20,
                      width: ResponsiveHelper.isDesktop(context) ?  25 :ResponsiveHelper.isTab(context) ? 25 : 20,
                    ),
                  ),
                  title !=null && title!.trim() != "" ? Text( title!.tr,style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)
                  ),) : const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void route(bool isRoute, String? token, String errorMessage, String? tempToken, UserInfoModel? userInfoModel, String? socialLoginMedium, String? userName, String? email) async {
    if (isRoute) {
      if(token != null){
        if(Get.find<LocationController>().getUserAddress() !=null){
          Get.offAllNamed(RouteHelper.getMainRoute("home"));
        }else{
          Get.offAllNamed(RouteHelper.pickMap);
        }

      }else if(tempToken != null){
        Get.toNamed(RouteHelper.getUpdateProfileRoute(email: email ?? "", tempToken: tempToken, userName: userName ?? ""));

      }else if(userInfoModel != null){
        showModalBottomSheet(
          context: Get.context!,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (context) => ExistingAccountBottomSheet(userInfoModel: userInfoModel, socialLoginMedium: socialLoginMedium!),
          backgroundColor: Colors.transparent,
        );
      }
      else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(errorMessage),
            backgroundColor: Colors.red));
      }

    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(errorMessage),
          backgroundColor: Colors.red));
    }
  }



  Future<void> _onTap ({required SocialLoginType socialLoginType,String? fromPage}) async {

    if(socialLoginType == SocialLoginType.google){

      final SocialLogInBody? socialLoginModel = await Get.find<AuthController>().googleLogin();


      if(socialLoginModel != null) {
        Get.find<AuthController>().loginWithSocialMedia(
          socialLoginModel, route, fromPage: fromPage,
        );
      }
    }

    else if(socialLoginType == SocialLoginType.facebook){
      final SocialLogInBody? socialLoginModel =  await Get.find<AuthController>().facebookLogin();

      if(socialLoginModel != null) {
        Get.find<AuthController>().loginWithSocialMedia(socialLoginModel, route ,fromPage: fromPage);
      }
    } else if(socialLoginType == SocialLoginType.apple){
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      Get.find<AuthController>().loginWithSocialMedia(SocialLogInBody(
          email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode, medium: "apple",
          guestId: Get.find<SplashController>().getGuestId(),
        userName: credential.givenName ?? credential.familyName
      ),route,fromPage: fromPage);
    }
  }
}
