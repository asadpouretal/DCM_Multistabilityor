# Dynamic Causal Modelling (DCM) Validation of Multistable Cortical Circuits

This repository provides MATLAB scripts, helper functions, and analysis code for simulating and evaluating multistable cortical neural dynamics through Dynamic Causal Modelling (DCM). It specifically explores dynamics characterized by bistable fixed points (decision-making), period doubling, and deterministic chaos, accompanied by detailed instructions and scripts to replicate the analyses and figures from our manuscript.

---

## Repository Structure

```bash
DCM_Multistability/
│
├── Bistable_fixed_points/
│   └── MATLAB_Codes/
│       ├── main_for_3neurons_correct.m
│       ├── main_for_3neurons_correct_2.m
│       ├── main_for_3neurons_correct_3.m
│       ├── main_for_3neurons_correct_4.m
│       ├── main_for_3neurons_error.m
│       ├── main_for_3neurons_error_2.m
│       ├── main_for_3neurons_error_3.m
│       ├── main_for_3neurons_error_4.m
│       └── helper_functions/
│
├── Period_doubling/
│   └── MATLAB_Codes/
│       ├── main_for_period_doubling.m
│       └── helper_functions/
│
├── Chaos/
│   └── MATLAB_Codes/
│       ├── main_for_chaos.m
│       └── helper_functions/
│
├── Figures/
│   ├── Fig_S1/
│   │   ├── Fig_S1.m
│   │   └── helper_functions/
│   ├── Fig2/
│   │   ├── FIG2_D_F.m
│   │   ├── FIG2_G_I.m
│   │   └── helper_functions/
│   └── Fig3/
│       ├── FIG3.m
│       └── helper_functions/
│
├── README.md
└── LICENSE
```

---

## Getting Started

### Requirements:
- MATLAB (recommended version R2023b)
- SPM12 Toolbox
- Parallel Computing Toolbox (optional, recommended for performance)

### Instructions:
Update all paths inside MATLAB scripts to match your local environment before running.

### Simulation Scripts:

#### Bistable Fixed Points
Run these scripts individually according to trial types (correct or error) and evidence quality levels:
```matlab
main_for_3neurons_correct.m
main_for_3neurons_correct_2.m
main_for_3neurons_correct_3.m
main_for_3neurons_correct_4.m

main_for_3neurons_error.m
main_for_3neurons_error_2.m
main_for_3neurons_error_3.m
main_for_3neurons_error_4.m
```

#### Period Doubling
Navigate to `Period_doubling/MATLAB_Codes` and run:
```matlab
main_for_period_doubling.m
```

### Chaos
Navigate to `Chaos/MATLAB_Codes` and run:
```matlab
main_for_chaos.m
```

---

## Generating Figures

To reproduce the figures from the manuscript:

- **Fig S1** (Non-decision trial simulation):
```matlab
Figures/Fig_S1/Fig_S1.m
```

- **Fig 2** (Psychophysical analyses and Bayesian model selection):
```matlab
Figures/Fig2/FIG2_D_F.m
Figures/Fig2/FIG2_G_I.m
```

- **Fig 3** (Period doubling and chaos dynamics analysis):
```matlab
Figures/Fig3/FIG3.m
```

Helper functions required for the figures are included within each respective figure folder.

---

## Citation

Please cite our manuscript if you use this repository:

> Asadpour, A., Azimi, A., & Wong-Lin, K. (2024). *Limitations of Dynamic Causal Modelling for Multistable Cortical Circuits.*

### Contact
- **Corresponding Author:** KongFatt Wong-Lin ([k.wong-lin@ulster.ac.uk](mailto:k.wong-lin@ulster.ac.uk))

---

## License

Distributed under the GNU General Public License v3.0 (GPL-3.0).

