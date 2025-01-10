import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:swiss_gold/core/utils/enum/view_state.dart';
import 'package:swiss_gold/core/utils/image_assets.dart';
import 'package:swiss_gold/core/utils/widgets/category_shimmer.dart';
import 'package:swiss_gold/core/view_models/company_profile_view_model.dart';
import 'package:swiss_gold/views/support/widgets/contact_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompanyProfileViewModel>(context, listen: false)
          .fetchCompanyProfile();
    });
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child:
            Consumer<CompanyProfileViewModel>(builder: (context, model, child) {
          if (model.state == ViewState.loading) {
            return GridView.builder(
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 50.h,
                    crossAxisSpacing: 50.w),
                itemBuilder: (context, index) {
                  return CategoryShimmer();
                });
          } else if (model.companyProfileModel == null ||
              model.companyProfileModel!.data == null) {
            return SizedBox.shrink();
          } else {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ContactCard(
                      icon: ImageAssets.whatsapp,
                      title: 'Whatsapp',
                      onTap: () {
                        openUrl(
                            'https://wa.me/${model.companyProfileModel!.data.contact}');
                      },
                    ),
                    ContactCard(
                      icon: ImageAssets.whatsapp,
                      title: 'Gmail',
                      onTap: () {
                        openUrl(
                            'mailto:${model.companyProfileModel!.data.email}'); // Gmail
                      },
                    ),
                  ],
                ),
                ContactCard(
                  icon: ImageAssets.phone,
                  title: 'Contact',
                  onTap: () {
                    openUrl(model.companyProfileModel!.data.contact.toString());
                  },
                ),
              ],
            );
          }
        }));
  }
}
