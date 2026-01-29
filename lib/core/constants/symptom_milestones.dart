class SymptomMilestone {
  final String id;
  final int hourThreshold;
  final String title;
  final String status;
  final String description;
  final String sensation;
  final String science;
  final String? recoveryBenefit;

  const SymptomMilestone({
    required this.id,
    required this.hourThreshold,
    required this.title,
    required this.status,
    required this.description,
    required this.sensation,
    required this.science,
    this.recoveryBenefit,
  });
}

class SymptomMilestones {
  static const Map<String, List<SymptomMilestone>> habitMappings = {
    'alcohol': [
      SymptomMilestone(
        id: 'alc_0',
        hourThreshold: 0,
        title: "Hour Zero",
        status: "Metabolic Initiation",
        description:
            "Your body begins the process of filtering the last ethanol intake.",
        sensation: "Nausea / Fatigue",
        science:
            "This is the energy cost of your liver prioritizing toxin removal over digestion.",
        recoveryBenefit:
            "Blood alcohol concentration begins its descent to zero.",
      ),
      SymptomMilestone(
        id: 'alc_24',
        hourThreshold: 24,
        title: "24 Hours",
        status: "GABA/Glutamate Storm",
        description: "Blood sugar normalizes, but your brain is hyper-excited.",
        sensation: "Anxiety & Tremors",
        science:
            "Glutamate is flooding the brain. This is temporary 'over-wiring' while the brakes (GABA) are repaired.",
        recoveryBenefit: "Hypoglycemia risk drops significantly.",
      ),
      SymptomMilestone(
        id: 'alc_72',
        hourThreshold: 72,
        title: "72 Hours",
        status: "Peak Neuro-Adjustment",
        description: "Alcohol is fully eliminated from the bloodstream.",
        sensation: "Exhaustion & Irritability",
        science:
            "Your body has been running a marathon to clear toxins. The exhaustion is a demand for restorative rest.",
        recoveryBenefit: "Physical dependence is broken.",
      ),
    ],
    'weed': [
      SymptomMilestone(
        id: 'weed_24',
        hourThreshold: 24,
        title: "24 Hours",
        status: "Hypothalamus Reset",
        description:
            "The body's thermostat and appetite regulators begin to reset.",
        sensation: "Cold Sweats / No Appetite",
        science:
            "Without cannabinoids to stimulate the hypothalamus, body temp and hunger signals are temporarily offline.",
        recoveryBenefit: "Lung cilia begin beating again to clear mucus.",
      ),
      SymptomMilestone(
        id: 'weed_72',
        hourThreshold: 72,
        title: "3 Days",
        status: "Peak REM Rebound",
        description: "THC is leaving fat cells. REM sleep suppression lifts.",
        sensation: "Intense/Wild Dreams",
        science:
            "Your brain is prioritizing REM sleep to process unfiled memories.",
        recoveryBenefit: "Deep oxygen intake improves.",
      ),
    ],
    'nicotine': [
      SymptomMilestone(
        id: 'nic_72',
        hourThreshold: 72,
        title: "3 Days",
        status: "Nicotine Free",
        description: "Nicotine is 100% eliminated from the body.",
        sensation: "Peak Irritability",
        science:
            "This is the 'extinction burst'—the final tantrum of the addiction pathways.",
        recoveryBenefit: "Bronchial tubes relax; breathing becomes easier.",
      ),
    ],
    'nofap': [
      SymptomMilestone(
        id: 'nf_336',
        hourThreshold: 336,
        title: "14 Days",
        status: "Dopamine D2 Healing",
        description: "Brain begins to repair desensitized dopamine receptors.",
        sensation: "The Flatline (Dead Libido)",
        science:
            "The brain shuts down libido to facilitate deep repair of reward pathways.",
        recoveryBenefit: "Reduced 'brain fog' and improved eye contact.",
      ),
    ],
    'caffeine': [
      SymptomMilestone(
        id: 'caf_24',
        hourThreshold: 24,
        title: "24 Hours",
        status: "Cerebral Vasodilation",
        description:
            "Blood vessels in the brain are rapidly expanding to natural size.",
        sensation: "Throbbing Headache",
        science:
            "Pain is caused by expansion of blood vessels increasing pressure. Sign of increased oxygen delivery.",
        recoveryBenefit: "Brain oxygenation levels increasing.",
      ),
    ],
  };
}
