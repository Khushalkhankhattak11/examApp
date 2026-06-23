import 'package:flutter/material.dart';

enum LegalDocumentType { privacyPolicy, termsAndConditions }

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocumentType type;

  const LegalDocumentScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final document = type == LegalDocumentType.privacyPolicy
        ? _privacyPolicy
        : _termsAndConditions;

    return Scaffold(
      backgroundColor: const Color(0xFF131409),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131409),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF353629)),
        ),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
          children: [
            Text(
              'Last updated: 23 June 2026',
              style: TextStyle(
                color: const Color(0xFFD8EE36).withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              document.introduction,
              style: const TextStyle(
                color: Color(0xFFE5E6D3),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            for (final section in document.sections) ...[
              _LegalSection(section: section),
              const SizedBox(height: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final _LegalSectionData section;

  const _LegalSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          section.body,
          style: const TextStyle(
            color: Color(0xFFC7C8AE),
            fontSize: 14,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}

class _LegalDocumentData {
  final String title;
  final String introduction;
  final List<_LegalSectionData> sections;

  const _LegalDocumentData({
    required this.title,
    required this.introduction,
    required this.sections,
  });
}

class _LegalSectionData {
  final String title;
  final String body;

  const _LegalSectionData(this.title, this.body);
}

const _privacyPolicy = _LegalDocumentData(
  title: 'Privacy Policy',
  introduction:
      'ExamAce respects your privacy. This policy explains what information '
      'the app handles, why it is used, and the choices available to you when '
      'you use ExamAce.',
  sections: [
    _LegalSectionData(
      '1. Information we collect',
      'Account and profile information may include your name, email address, '
          'age, city, education details, selected examination and user ID. We also '
          'store learning activity such as quiz answers, saved questions, scores, '
          'test history, progress and streaks.\n\n'
          'For notifications, the app may process a device messaging token and '
          'notification interactions. If you choose “Use current location,” the '
          'app accesses your location to determine or fill in your city. ExamAce '
          'does not request background location access.',
    ),
    _LegalSectionData(
      '2. How we use information',
      'We use information to create and secure your account, personalize exam '
          'preparation, deliver quizzes and mock tests, calculate progress, provide '
          'results and insights, send requested notifications, maintain the app, '
          'prevent abuse and improve reliability.',
    ),
    _LegalSectionData(
      '3. AI-assisted features',
      'Some explanations or insights may be generated with artificial '
          'intelligence. When an AI feature is used, the information needed for '
          'that request may be processed by the AI service provider. Do not enter '
          'confidential or sensitive personal information into an AI prompt. AI '
          'output may be incomplete or inaccurate and should be verified.',
    ),
    _LegalSectionData(
      '4. Services that process data',
      'ExamAce uses service providers such as Google Firebase for '
          'authentication, cloud data storage and messaging. Device or platform '
          'location and geocoding services are used only when you request location '
          'assistance. Google generative AI services may support AI-assisted '
          'features. These providers process information under their own terms and '
          'privacy practices.',
    ),
    _LegalSectionData(
      '5. Sharing and sale of data',
      'We do not sell your personal information. Information may be shared '
          'with service providers only as needed to operate ExamAce, or when '
          'required by law, necessary to protect users, or needed to investigate '
          'fraud, abuse or security incidents.',
    ),
    _LegalSectionData(
      '6. Retention and account deletion',
      'Information is retained while your account is active and as reasonably '
          'needed to provide the service or meet legal and security obligations. '
          'You can delete your account from the Profile screen. Account deletion '
          'removes your authentication account and associated profile, onboarding, '
          'progress, notification and messaging-token data handled by ExamAce, '
          'subject to necessary backup, legal or fraud-prevention retention.',
    ),
    _LegalSectionData(
      '7. Your choices',
      'You may deny or revoke location and notification permissions in your '
          'device settings. You can enter your city manually instead of using '
          'location. You may update available profile information, sign out, or '
          'delete your account from within the app.',
    ),
    _LegalSectionData(
      '8. Security',
      'We use reasonable technical and organizational safeguards, including '
          'authenticated access and encrypted network connections. No electronic '
          'storage or transmission method can be guaranteed to be completely '
          'secure.',
    ),
    _LegalSectionData(
      '9. Children’s privacy',
      'ExamAce is intended for exam-preparation users who meet the minimum age '
          'required to create an account under applicable law. If you believe a '
          'child has provided personal information without appropriate consent, '
          'contact us so the account can be reviewed and removed.',
    ),
    _LegalSectionData(
      '10. Changes and contact',
      'We may update this policy when ExamAce or applicable requirements '
          'change. The updated date will appear at the top of this page. Privacy '
          'questions or requests can be sent to the ExamAce support address shown '
          'on the app’s Google Play store listing.',
    ),
  ],
);

const _termsAndConditions = _LegalDocumentData(
  title: 'Terms & Conditions',
  introduction:
      'These terms govern your use of ExamAce. By creating an account or using '
      'the app, you agree to these terms. If you do not agree, please do not '
      'use ExamAce.',
  sections: [
    _LegalSectionData(
      '1. Eligibility and accounts',
      'You must be legally able to accept these terms. You agree to provide '
          'accurate account information, protect your password and promptly notify '
          'ExamAce support of suspected unauthorized access. You are responsible '
          'for activity performed through your account.',
    ),
    _LegalSectionData(
      '2. Educational purpose',
      'ExamAce provides study materials, quizzes, mock tests, progress tools '
          'and educational guidance. It does not guarantee examination admission, '
          'eligibility, rankings, scores, employment or any other result. Always '
          'confirm official syllabi, dates, rules and requirements with the '
          'relevant examination authority.',
    ),
    _LegalSectionData(
      '3. Independent service',
      'ExamAce is an independent exam-preparation service. It is not '
          'affiliated with, authorized by or endorsed by FPSC, NTS, FIA or any '
          'government department or examination authority unless explicitly '
          'stated otherwise.',
    ),
    _LegalSectionData(
      '4. AI-generated information',
      'AI-generated explanations and insights can contain errors, omissions or '
          'outdated information. They are provided as study assistance and must '
          'not be treated as official, professional or definitive advice. You '
          'remain responsible for checking important information.',
    ),
    _LegalSectionData(
      '5. Acceptable use',
      'You must not misuse ExamAce, interfere with its operation, attempt '
          'unauthorized access, extract data in bulk, reverse engineer protected '
          'components, distribute malicious code, impersonate another person, '
          'infringe intellectual-property rights or use the service unlawfully.',
    ),
    _LegalSectionData(
      '6. Content and intellectual property',
      'The ExamAce name, interface, software, graphics and original educational '
          'content are protected by applicable intellectual-property laws. You '
          'receive a limited, personal, non-exclusive and revocable right to use '
          'the app for lawful study purposes. No ownership rights are transferred.',
    ),
    _LegalSectionData(
      '7. Payments and premium features',
      'ExamAce may introduce optional paid features or subscriptions. Prices, '
          'billing periods, renewals and trial conditions will be shown before '
          'purchase. Purchases made through Google Play are also governed by '
          'Google Play’s billing and refund rules.',
    ),
    _LegalSectionData(
      '8. Availability and changes',
      'We may update, add, remove or temporarily suspend features to maintain '
          'security, reliability or the quality of the service. We do not promise '
          'that ExamAce will always be uninterrupted, error-free or available on '
          'every device.',
    ),
    _LegalSectionData(
      '9. Suspension and termination',
      'We may restrict or terminate access when these terms are violated, '
          'security is threatened or the law requires it. You may stop using the '
          'service at any time and can delete your account from the Profile screen.',
    ),
    _LegalSectionData(
      '10. Disclaimer and liability',
      'To the extent permitted by law, ExamAce is provided “as is” and without '
          'warranties of guaranteed results, accuracy or uninterrupted operation. '
          'ExamAce will not be liable for indirect or consequential losses arising '
          'from reliance on study content, AI output, third-party services or '
          'inability to access the app. Rights that cannot legally be excluded '
          'remain unaffected.',
    ),
    _LegalSectionData(
      '11. Governing law',
      'These terms are governed by the applicable laws of Pakistan, without '
          'excluding any mandatory consumer protections that apply where you live.',
    ),
    _LegalSectionData(
      '12. Changes and contact',
      'We may update these terms and will revise the date shown above. '
          'Continued use after an update means you accept the revised terms where '
          'permitted by law. Questions can be sent to the ExamAce support address '
          'shown on the app’s Google Play store listing.',
    ),
  ],
);
