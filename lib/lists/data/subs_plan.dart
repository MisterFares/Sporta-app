import 'package:fit/classes/subs_plan.dart';

List<SubscriptionPlan> subscriptionPlans = [
  SubscriptionPlan(
    id: 1,
    name: "Silver",
    price: 29.99,
    duration: "30 days",
    description: "Essential plan for beginners",
    features: ["Weekly check-ins", "Basic analytics", "Email support"],
    createdAt: "2024-01-01",
  ),
  SubscriptionPlan(
    id: 2,
    name: "Gold",
    price: 49.99,
    duration: "30 days",
    description: "Most popular plan for serious athletes",
    features: [
      "2x weekly check-ins",
      "Advanced analytics",
      "Priority support",
      "Custom macros",
    ],
    createdAt: "2024-01-01",
  ),
  SubscriptionPlan(
    id: 3,
    name: "Platinum",
    price: 99.99,
    duration: "30 days",
    description: "Elite plan for maximum results",
    features: [
      "Daily check-ins",
      "Full analytics suite",
      "24/7 chat support",
      "Custom programming",
      "Video form analysis",
    ],
    createdAt: "2024-01-01",
  ),
];
