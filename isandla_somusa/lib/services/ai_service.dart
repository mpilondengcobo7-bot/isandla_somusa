import '../models/donation_model.dart';
import '../models/user_model.dart';
import '../utils/helpers.dart';

/// AI Matching & NLP Service
/// Uses rule-based scoring + keyword sentiment for the matching engine.
/// Extend by plugging in a real ML API (e.g. Vertex AI, Claude API).
class AiService {

  // ── AI Donor-Recipient matching score ──────────────────────────────
  /// Returns a score 0.0–1.0 for how well a donation suits a recipient.
  static double matchScore({
    required DonationModel donation,
    required UserModel recipient,
    required double recipientLat,
    required double recipientLng,
  }) {
    double score = 0.0;

    // 1. Proximity (40% weight) — closer = higher score
    final km = Helpers.distanceKm(
      donation.latitude, donation.longitude,
      recipientLat, recipientLng,
    );
    if (km <= 1)       score += 0.40;
    else if (km <= 3)  score += 0.30;
    else if (km <= 5)  score += 0.20;
    else if (km <= 10) score += 0.10;

    // 2. Expiry urgency (30% weight) — expiring soon → higher priority
    final hoursLeft = donation.expiryDate.difference(DateTime.now()).inHours;
    if (hoursLeft <= 3)       score += 0.30;
    else if (hoursLeft <= 6)  score += 0.25;
    else if (hoursLeft <= 12) score += 0.20;
    else if (hoursLeft <= 24) score += 0.15;
    else                      score += 0.05;

    // 3. Recipient history (15% weight) — active recipients score higher
    if (recipient.totalPickups >= 10) score += 0.15;
    else if (recipient.totalPickups >= 5) score += 0.10;
    else if (recipient.totalPickups >= 1) score += 0.05;

    // 4. Donor rating (15% weight) — higher-rated donors score better
    if (donation.donorRating >= 4.5) score += 0.15;
    else if (donation.donorRating >= 3.5) score += 0.10;
    else if (donation.donorRating >= 2.5) score += 0.05;

    return score.clamp(0.0, 1.0);
  }

  /// Sort donations by match score for a given recipient
  static List<DonationModel> rankDonations({
    required List<DonationModel> donations,
    required UserModel recipient,
    required double recipientLat,
    required double recipientLng,
  }) {
    final scored = donations.map((d) => MapEntry(
      d,
      matchScore(
        donation: d,
        recipient: recipient,
        recipientLat: recipientLat,
        recipientLng: recipientLng,
      ),
    )).toList();
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  // ── NLP Sentiment Analysis ─────────────────────────────────────────
  /// Classify a feedback comment as positive / neutral / negative.
  static String analyseSentiment(String text) {
    final lower = text.toLowerCase();

    final positiveWords = [
      'great', 'excellent', 'amazing', 'good', 'wonderful', 'fantastic',
      'helpful', 'kind', 'generous', 'fresh', 'clean', 'perfect', 'love',
      'thank', 'appreciated', 'recommend', 'quick', 'reliable', 'friendly',
    ];
    final negativeWords = [
      'bad', 'poor', 'terrible', 'awful', 'late', 'rude', 'expired',
      'spoiled', 'rotten', 'cold', 'dirty', 'not', 'never', 'horrible',
      'disappointing', 'waste', 'wrong', 'missing', 'incomplete',
    ];

    int pos = 0, neg = 0;
    for (final w in positiveWords) { if (lower.contains(w)) pos++; }
    for (final w in negativeWords) { if (lower.contains(w)) neg++; }

    if (pos > neg)      return 'positive';
    if (neg > pos)      return 'negative';
    return 'neutral';
  }

  // ── Chatbot responses ──────────────────────────────────────────────
  static String chatbotReply(String message) {
    final lower = message.toLowerCase().trim();

    if (_matches(lower, ['hello', 'hi', 'hey', 'sawubona'])) {
      return 'Sawubona! Welcome to Somusa. How can I help you today? '
          'You can ask me about donating food, requesting food, or how Somusa works.';
    }
    if (_matches(lower, ['donate', 'donation', 'give', 'post food'])) {
      return 'To donate food: tap the + button on your home screen, fill in the '
          'food details (title, quantity, expiry date), set a pickup time, and post. '
          'Recipients near you will be notified!';
    }
    if (_matches(lower, ['request', 'find food', 'get food', 'hungry', 'need food'])) {
      return 'To request food: browse the available donations on the home screen, '
          'tap on one that suits you, select a pickup time, and send a request. '
          'The donor will approve or decline.';
    }
    if (_matches(lower, ['pickup', 'collect', 'collection'])) {
      return 'Once your request is approved, you will receive a notification with '
          'the pickup address and your confirmed time slot. Please arrive on time!';
    }
    if (_matches(lower, ['rating', 'rate', 'review', 'feedback'])) {
      return 'After a successful pickup, both the donor and recipient can rate each '
          'other from 1–5 stars. Your rating helps build trust in the Somusa community.';
    }
    if (_matches(lower, ['cancel', 'delete'])) {
      return 'You can cancel a donation or request from your profile screen before '
          'it is approved. Once approved, please contact the other party directly.';
    }
    if (_matches(lower, ['map', 'location', 'near me', 'close'])) {
      return 'The map screen shows all available donations near you. '
          'Tap a pin to see details and request food. Enable location permission '
          'for the best results.';
    }
    if (_matches(lower, ['halaal', 'vegetarian', 'allergy', 'allergen'])) {
      return 'Donors can mark food as Halaal or Vegetarian and list allergens '
          'when posting. Filter donations by dietary needs on the home screen.';
    }
    if (_matches(lower, ['popia', 'privacy', 'data', 'security'])) {
      return 'Somusa complies with POPIA. Your personal data is securely stored '
          'and never shared without your consent. You can delete your account '
          'at any time from Settings.';
    }
    if (_matches(lower, ['help', 'support', 'contact'])) {
      return 'For support, email us at support@somusa.co.za or visit our website. '
          'I can also help you with donations, requests, pickups, and ratings — just ask!';
    }
    if (_matches(lower, ['thank', 'dankie', 'ngiyabonga'])) {
      return 'Ngiyabonga! Thank you for using Somusa — together we are making '
          'a difference, one meal at a time.';
    }

    return 'I\'m not sure I understood that. You can ask me about donating food, '
        'requesting food, pickups, ratings, or how Somusa works. '
        'Type "help" for more options.';
  }

  static bool _matches(String input, List<String> keywords) =>
      keywords.any((k) => input.contains(k));
}
