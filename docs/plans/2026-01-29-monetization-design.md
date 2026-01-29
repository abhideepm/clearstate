# TrueState Monetization Design

> Final design document for TrueState monetization strategy

---

## 1. Tier Structure

### Free Tier

| Feature            | Included              |
| ------------------ | --------------------- |
| Habits tracked     | **2 habits max**      |
| Timer + milestones | ✅                    |
| Basic timeline     | ✅                    |
| Local data storage | ✅                    |
| 7-day Pro trial    | ✅ (on first install) |

### Pro Tier

| Feature                           | Included      |
| --------------------------------- | ------------- |
| Habits tracked                    | **Unlimited** |
| AI Sponsor                        | ✅            |
| Symptom Correlation Engine        | ✅            |
| Deep Analytics (heatmaps, trends) | ✅            |
| Premium themes                    | ✅            |
| Custom home widgets               | ✅            |
| Cloud backup                      | ✅            |

---

## 2. Pricing

| Plan         | Price  | Notes                          |
| ------------ | ------ | ------------------------------ |
| **Monthly**  | $4.99  | Undercuts I Am Sober ($9.99)   |
| **Annual**   | $39.99 | ~33% savings                   |
| **Lifetime** | $79    | Unlimited initially; cap later |

**7-day trial**: Full Pro access, auto-downgrades to Free on Day 8.

---

## 3. AI Sponsor — What Is It?

The AI Sponsor is a **24/7 in-app support system** for crisis moments. Here's how it works:

### Core Use Case: "I'm About to Relapse"

When a user feels an urge, they hit the **"I'm Struggling"** button. The AI Sponsor:

1. **Acknowledges** the moment without judgment

   > "I hear you. Urges are intense but temporary. Let's get through this together."

2. **Guides "Urge Surfing"** — a 10-minute delay tactic:
   - Breathing exercise (4-7-8 pattern)
   - Distraction task (e.g., "Name 5 things you can see")
   - Timer showing "Urges typically peak at 10 mins, then fade"

3. **Provides Contextual Tips** based on the habit:
   - Alcohol: "Drink a glass of water. The craving isn't hunger—it's habit."
   - NoFap: "Close the app. Do 20 pushups. Your brain is seeking dopamine—give it a healthy hit."
   - Smoking: "Chew gum or a toothpick. The oral fixation is half the craving."

4. **Logs the Urge** for correlation later:
   - "You resisted an urge at 11 PM. Great work."
   - This feeds the Symptom Correlation Engine.

### Why It Drives Conversions

- **24/7 availability**: No human sponsor is awake at 3 AM
- **No shame**: Users won't admit to a friend they're struggling; they'll tell an AI
- **Tangible value**: Users who survive even ONE urge with the AI become converts

### Implementation Options

| Approach                                 | Pros                   | Cons                                  |
| ---------------------------------------- | ---------------------- | ------------------------------------- |
| **On-device LLM** (e.g., Gemma, Mistral) | Private, no API costs  | Limited intelligence, larger app size |
| **Cloud LLM** (GPT-4, Claude)            | Smarter responses      | API costs, privacy concerns           |
| **Scripted flows** (no LLM)              | Zero cost, predictable | Feels robotic, less personalized      |

**Recommendation**: Start with **scripted urge-surfing flows** (no LLM). Add LLM as a future Pro+ tier.

---

## 4. Referral Program

### Mechanics

| Action                      | Reward                          |
| --------------------------- | ------------------------------- |
| Refer a friend who signs up | 7 days Pro free (for referrer)  |
| Friend subscribes to Pro    | 1 month Pro free (for referrer) |
| 3 successful referrals      | Lifetime Pro unlock             |

### Implementation

1. **Unique referral code** per user (e.g., `CLEARSTATE-ABHIDEEP`)
2. **Share sheet** with pre-written message:
   > "I've been using TrueState for my recovery—it's helped me track [X] days sober. Try it free: [link with code]"
3. **Track referrals** via App Store attribution or deep links

### Anti-Abuse

- Max 10 referral rewards per user (prevents farming)
- Friend must be active for 7+ days before reward triggers

---

## 5. Feedback System

### In-App Feedback Buttons

**Placement:**

- Settings screen → "Send Feedback"
- After completing 7-day trial → "How was Pro?"
- On paywall screen → "Not ready? Tell us why"

**Implementation:**

```
┌─────────────────────────────┐
│  How are we doing?          │
│                             │
│  [😊]  [😐]  [😞]           │
│                             │
│  Optional: Tell us more     │
│  ┌─────────────────────┐    │
│  │                     │    │
│  └─────────────────────┘    │
│                             │
│  [ Submit ]                 │
└─────────────────────────────┘
```

**Data Captured:**

- Rating (1-3 emoji scale)
- Optional text feedback
- Screen they came from
- Pro/Free status
- Days since install

### Feedback Routing

- Negative feedback (😞) → Email alert to you
- All feedback → Logged for analysis

---

## 6. A/B Testing Plan

### What to Test

| Test               | Variants                                  | Success Metric    |
| ------------------ | ----------------------------------------- | ----------------- |
| **Trial length**   | 7 days vs 14 days                         | Conversion to Pro |
| **Paywall timing** | After trial vs after first limitation hit | Conversion rate   |
| **Lifetime price** | $79 vs $99 vs $119                        | Revenue per user  |
| **Monthly price**  | $4.99 vs $6.99                            | Subscription rate |

### Implementation

1. Use **RevenueCat** for subscription management + A/B testing (built-in)
2. Assign users to cohorts on first launch
3. Log variant in analytics for correlation

### Phase 1 Tests (Launch)

| Test           | Control | Variant | Duration |
| -------------- | ------- | ------- | -------- |
| Lifetime price | $79     | $99     | 4 weeks  |
| Trial length   | 7 days  | 14 days | 4 weeks  |

---

## 7. App Store Subscription Flow

### Technical Implementation

1. **RevenueCat SDK** — handles iOS/Android subscriptions, trials, and analytics
2. **Entitlements**: `pro_access` (single entitlement for all Pro features)
3. **Products** (configure in App Store Connect + Google Play):
   - `truestate_pro_monthly` ($4.99)
   - `truestate_pro_annual` ($39.99)
   - `truestate_pro_lifetime` ($79)

### User Flow

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  First Launch                                            │
│       │                                                  │
│       ▼                                                  │
│  ┌─────────────────┐                                     │
│  │ Start 7-Day     │                                     │
│  │ Pro Trial       │                                     │
│  └────────┬────────┘                                     │
│           │                                              │
│           ▼                                              │
│  ┌─────────────────┐     ┌──────────────────┐            │
│  │ Day 5: Nudge    │────▶│ Show Paywall     │            │
│  │ "3 days left"   │     │ with pricing     │            │
│  └─────────────────┘     └────────┬─────────┘            │
│                                   │                      │
│           ┌───────────────────────┼──────────────┐       │
│           │                       │              │       │
│           ▼                       ▼              ▼       │
│  ┌─────────────┐      ┌───────────────┐  ┌───────────┐   │
│  │ Subscribe   │      │ Buy Lifetime  │  │ Continue  │   │
│  │ Monthly/Yr  │      │ $79           │  │ Free      │   │
│  └─────────────┘      └───────────────┘  └───────────┘   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Paywall Design Principles

1. **Lead with value**: Show what they'll lose, not features list
   > "Keep your insights: Your correlation data, unlimited habits, and AI support"
2. **Anchor on lifetime**: Show $79 lifetime first, then monthly/annual feel cheap
3. **No hard blocks**: Free tier is usable, just limited

---

## 8. Implementation Priority

### Phase 1: MVP Monetization (Week 1-2)

- [ ] RevenueCat SDK integration
- [ ] 2-habit limit enforcement
- [ ] Trial start/end logic
- [ ] Basic paywall UI
- [ ] Products in App Store Connect

### Phase 2: Conversion Features (Week 3-4)

- [ ] AI Sponsor (scripted urge-surfing flow)
- [ ] Feedback buttons
- [ ] Trial expiry notifications

### Phase 3: Growth (Week 5+)

- [ ] Referral program
- [ ] Premium themes
- [ ] A/B testing setup

---

## 9. Revenue Projections

| Scenario         | Users/Month | Conversion | ARPU  | Monthly Revenue |
| ---------------- | ----------- | ---------- | ----- | --------------- |
| **Conservative** | 1,000       | 3%         | $4.99 | $150            |
| **Moderate**     | 5,000       | 5%         | $6.50 | $1,625          |
| **Optimistic**   | 10,000      | 7%         | $8.00 | $5,600          |

_ARPU assumes mix of monthly, annual, and lifetime._

---

## Summary

| Decision         | Final Choice                         |
| ---------------- | ------------------------------------ |
| Free habit limit | 2                                    |
| Trial length     | 7 days                               |
| Monthly price    | $4.99                                |
| Annual price     | $39.99                               |
| Lifetime price   | $79 (unlimited for now)              |
| AI Sponsor       | Scripted flows first, LLM later      |
| Referral         | 7 days Pro per signup, lifetime at 3 |
| Feedback         | Emoji + optional text, 3 placements  |
| A/B tests        | Lifetime price, trial length         |
