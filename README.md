# Dynamic Causal Modelling (DCM) Validation of Multistable Cortical Circuits

This repository provides MATLAB scripts, helper functions, and analysis code for simulating and evaluating multistable cortical neural dynamics through **Dynamic Causal Modelling (DCM)**. It explores neural dynamics characterised by **bistable fixed points (decision-making)**, **period doubling**, **deterministic chaos**, and **single-steady-state control conditions**.

All scripts reproduce the analyses and figures presented in our manuscript:

> Asadpour, A., Azimi, A., & Wong-Lin, K. (2025). *Limitations of Variational Laplace-based Dynamic Causal Modelling for Multistable Cortical Circuits.*

---

## 🧠 Repository Structure

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
├── Single_point_steady_state/
│   ├── MATLAB_Codes/
│   │   ├── main_for_single_period_safe.m
│   │   ├── runBMS_pd.m
│   │   └── helper_functions/
│   ├── BMS/
│   │   └── results_BMS.mat
│   ├── simulated_data.mat
│   └── README.txt
│
├── Figures/
│   ├── Fig_S1/
│   │   ├── Fig_S1.m
│   │   └── helper_functions/
│   ├── Fig2/
│   │   ├── FIG2_D_F.m
│   │   ├── FIG2_G_I.m
│   │   └── helper_functions/
│   ├── Fig3/
│   │   ├── FIG3.m
│   │   └── helper_functions/
│   ├── Fig_S5/
│   │   ├── Fig_S5.m
│   │   └── helper_functions/
│   └── Fig_S7/
│       ├── Fig_S7.m
│       └── helper_functions/
│
├── README.md
└── LICENSE
```

---

## ⚙️ Getting Started

### Requirements
- MATLAB (recommended version **R2023b**)
- **SPM12** Toolbox  
- **Parallel Computing Toolbox** (optional but recommended for faster simulation)

### Setup
1. Clone or download this repository:
   ```bash
   git clone https://github.com/asadpouretal/DCM_Multistability.git
   ```
2. Add the relevant folders to your MATLAB path:
   ```matlab
   addpath(genpath('path_to_DCM_Multistability'));
   ```
3. Update any hardcoded file paths inside the scripts to match your local environment.

---

## 🧩 Simulation Scripts

### 1. Bistable Fixed Points
Run these scripts to simulate correct and error trials under different evidence quality levels:

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

---

### 2. Period Doubling

Navigate to:
```bash
Period_doubling/MATLAB_Codes/
```
and run:
```matlab
main_for_period_doubling.m
```

---

### 3. Chaos

Navigate to:
```bash
Chaos/MATLAB_Codes/
```
and run:
```matlab
main_for_chaos.m
```

---

### 4. Single-Steady-State Control (Fig. S5)

This control experiment tests DCM’s ability to estimate parameters in a **single steady-state regime** using balanced lateral couplings and increased self-excitation (c7 = 3).

Navigate to:
```bash
Single_point_steady_state/MATLAB_Codes/
```
and run sequentially:
```matlab
main_for_single_period_safe.m   % Simulate data and DCM estimation
runBMS_pd.m                     % Perform Bayesian Model Selection (BMS)
```

Results are saved in:
```
Single_point_steady_state/BMS/
```
and the simulated dataset (`simulated_data.mat`) is stored in:
```
Single_point_steady_state/
```

---

## 📊 Generating Figures

To reproduce the figures from the manuscript and supplementary material:

| Figure | Description | Script |
|:-------|:-------------|:-------|
| **Fig S1** | Non-decision trial simulation | `Figures/Fig_S1/Fig_S1.m` |
| **Fig 2** | Psychophysical analyses and Bayesian Model Selection for decision-making | `Figures/Fig2/FIG2_D_F.m`, `Figures/Fig2/FIG2_G_I.m` |
| **Fig 3** | Period-doubling and chaotic dynamics analysis | `Figures/Fig3/FIG3.m` |
| **Fig S5** | Single-steady-state control analysis | `Figures/Fig_S5/Fig_S5.m` |
| **Fig S7** | Free energy evolution across EM iterations | `Figures/Fig_S7/Fig_S7.m` |

Each figure folder includes its own helper functions for plotting and analysis.

---

## 🧾 Notes

- All DCM estimations use **SPM12**’s default settings, including **data normalisation** and **variational Laplace inference**.  
- Simulation outputs and estimated parameters are automatically saved as `.mat` files.  
- Figures reproduce all panels and results described in the main manuscript and Supplementary Figures **S1–S7**.  
- The single-steady-state control experiment demonstrates that DCM can reproduce normalised dynamics even when absolute connection magnitudes are underestimated due to compensatory scaling and SPM’s data normalisation.

---

## 📚 Citation

If you use this repository, please cite:

> Asadpour, A., Azimi, A., & Wong-Lin, K. (2025). *Limitations of Variational Laplace-based Dynamic Causal Modelling for Multistable Cortical Circuits.* Neuroinformatics.

---

## 📬 Contact

For questions or support, please contact:

**Corresponding Author:**  
Prof. **KongFatt Wong-Lin**  
📧 [k.wong-lin@ulster.ac.uk](mailto:k.wong-lin@ulster.ac.uk)

**Contributors:**  
- Abdoreza Asadpour  
- Amin Azimi  

---

## ⚖️ License

Distributed under the **GNU General Public License v3.0 (GPL-3.0)**.  
You are free to use, modify, and distribute this work with appropriate attribution.
