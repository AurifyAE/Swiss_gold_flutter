import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/services/local_storage.dart';
import 'package:swiss_gold/core/utils/colors.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/widgets/custom_outlined_btn.dart';
import 'package:swiss_gold/core/utils/widgets/custom_tile.dart';
import 'package:swiss_gold/core/view_models/profile_view_model.dart';
import 'package:swiss_gold/views/login/login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final isGuest = LocalStorage.getBool('isGuest');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: UIColor.gold,
            )),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Consumer<ProfileViewModel>(
          builder: (context, model, child) => model.state == ViewState.loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: UIColor.gold,
                  ),
                )
              : model.userModel == null
                  ? SizedBox.shrink()
                  : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.sp),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: UIColor.gold,
                            ),
                            borderRadius: BorderRadius.circular(100.sp),
                          ),
                          child: Icon(
                            PhosphorIcons.user(),
                            color: UIColor.gold,
                            size: 80.sp,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          model.userModel!.userName.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 32.sp,
                          ),
                        ),
                        Text(
                          model.userModel!.mobile.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 22.sp,
                          ),
                        ),
                        Text(
                          model.userModel!.location.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 22.sp,
                          ),
                        ),
                        Text(
                          model.userModel!.category.toUpperCase(),
                          style: TextStyle(
                            color: UIColor.gold,
                            fontSize: 22.sp,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        isGuest==false?
                        CustomOutlinedBtn(
                          borderRadius: 22.sp,
                          borderColor: UIColor.gold,
                          padH: 5.w,
                          padV: 15.h,
                          btnText: 'Change password',
                          btnTextColor: UIColor.gold,
                          onTapped: () {},
                        ):SizedBox.shrink(),
                        SizedBox(
                          height: 20.h,
                        ),
                        CustomOutlinedBtn(
                          borderRadius: 22.sp,
                          borderColor: UIColor.gold,
                          padH: 5.w,
                          padV: 15.h,
                          btnText: 'Logout',
                          btnTextColor: UIColor.gold,
                          onTapped: () {
                            LocalStorage.remove(['userId','userName','location','category','mobile','isGuest']).then(
                              (_) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginView(),
                                  ),
                                  (route)=> false
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
        ),
      ),
    );
  }
}
