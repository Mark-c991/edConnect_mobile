import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_mobile/models/providers/themeprovider.dart';
import 'package:edconnect_mobile/widgets/buttons.dart';
import 'package:edconnect_mobile/widgets/snackbars.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  final _userEmailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseCollectionProvider>(context);
    final currentColorSchemeProvider =
        Provider.of<ColorANDLogoProvider>(context);

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(int.parse(currentColorSchemeProvider.primaryColor)),
                Color(int.parse(currentColorSchemeProvider.secondaryColor))
              ],
            ),
          ),
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
              child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: true,
                  floating: true,
                  snap: true,
                  forceMaterialTransparency: true,
                  actionsIconTheme: const IconThemeData(color: Colors.white),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    AppLocalizations.of(context)!.globalSettingsLabel,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width < 700
                        ? MediaQuery.of(context).size.width
                        : MediaQuery.of(context).size.width / 2,
                    child: Card(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: _userEmailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!
                                        .globalEmptyFormFieldErrorLabel;
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: AppLocalizations.of(context)!
                                      .globalEmailLabel,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: PIPResponsiveRaisedButton(
                                  fontWeight: FontWeight.w600,
                                  label: AppLocalizations.of(context)!
                                      .globalSaveChangesButtonLabel,
                                  onPressed: () async {
                                    try {
                                      if (_formKey.currentState!.validate()) {
                                        await FirebaseAuth.instance.currentUser!
                                            .verifyBeforeUpdateEmail(
                                                _userEmailController.text)
                                            .then((value) {
                                          successMessage(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .settingsPageSuccessOnPersonalDataChangedSnackbarContent);
                                          FirebaseAnalytics.instance.logEvent(
                                              name: 'email_changed',
                                              parameters: {
                                                'user_id': FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                'timestamp': Timestamp.now()
                                                    .toDate()
                                                    .toString()
                                              });
                                        });

                                        final uid = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        var userCollection = FirebaseFirestore
                                            .instance
                                            .collection(databaseProvider
                                                .customerSpecificCollectionUsers);
                                        await userCollection.doc(uid).update({
                                          'email': _userEmailController.text
                                        });
                                      }
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      errorMessage(
                                          context,
                                          AppLocalizations.of(context)!
                                              .globalUnexpectedErrorLabel);
                                    }
                                  },
                                  width: MediaQuery.of(context).size.width),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}
