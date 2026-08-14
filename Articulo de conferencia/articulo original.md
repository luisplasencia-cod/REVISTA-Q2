\documentclass[conference]{IEEEtran}
\IEEEoverridecommandlockouts
% The preceding line is only needed to identify funding in the first footnote. If that is unneeded, please comment it out.
%Template version as of 6/27/2024
%\usepackage{subcaption}
\usepackage{cite}
\usepackage{amsmath,amssymb,amsfonts}
\usepackage{algorithmic}
\usepackage{graphicx}
\usepackage{textcomp}
\usepackage{xcolor}
\usepackage{float} % paquete añadido

\def\BibTeX{{\rm B\kern-.05em{\sc i\kern-.025em b}\kern-.08em
    T\kern-.1667em\lower.7ex\hbox{E}\kern-.125emX}}

\begin{document}

\title{Simulation-Driven Design and Functional Assessment of a Gait Simulator for Transtibial Prosthesis Evaluation \\
}

\author{
\IEEEauthorblockN{Adrian V. Galvez}
\IEEEauthorblockA{\textit{Biomechanics and Applied Robotics} \\
\textit{Research Laboratory}\\
\textit{Pontificia Universidad Catolica del Perú}\\
Lima, Peru \\
adrian.vilchez@pucp.edu.pe}
\and
\IEEEauthorblockN{Luis M. Plasencia}
\IEEEauthorblockA{\textit{Biomechanics and Applied Robotics} \\
\textit{Research Laboratory}\\
\textit{Pontificia Universidad Catolica del Perú}\\
Lima, Peru \\
luis.plasencia@pucp.edu.pe}
\and
\IEEEauthorblockN{Leonardo F. Machiavello}
\IEEEauthorblockA{\textit{Biomechanics and Applied Robotics} \\
\textit{Research Laboratory}\\
\textit{Pontificia Universidad Catolica del Perú}\\
Lima, Peru \\
leonardo.machiavello@pucp.edu.pe}
\and
\IEEEauthorblockN{Alberto A. Berrocal}
\IEEEauthorblockA{\textit{Biomechanics and Applied Robotics} \\
\textit{Research Laboratory}\\
\textit{Pontificia Universidad Catolica del Perú}\\
Lima, Peru \\
aberrocalt@pucp.edu.pe}

\and

\IEEEauthorblockN{ Victoria E. Abarca}
\IEEEauthorblockA{\textit{Biomechanics and Applied Robotics} \\
\textit{Research Laboratory}\\
\textit{Pontificia Universidad Catolica del Perú}\\
Lima, Peru \\
victoria.abarca@pucp.edu.pe}
\and
\IEEEauthorblockN{Dante A. Elias}
\IEEEauthorblockA{\textit{Biomechanics and Applied Robotics} \\
\textit{Research Laboratory}\\
\textit{Pontificia Universidad Catolica del Perú}\\
Lima, Peru \\
delias@pucp.pe}
}

\maketitle

\begin{abstract}
  Biomechanical gait simulators have become promising alternatives for prosthesis evaluation under controlled laboratory conditions. This work presents the design, implementation, and functional assessment of a three-degree-of-freedom (3-DOF) gait simulator for evaluating transtibial prostheses, featuring horizontal, vertical, and sagittal motion axes. The proposed platform adopts a reduced-degree-of-freedom architecture developed following a simulation-driven design methodology, combining CAD modeling, finite element analysis, analytical sizing of critical transmission components, and the integration of custom mechanical, electrical, electronic, and embedded control hardware. A functional assessment was performed using gait trajectories acquired from a healthy subject, marker-based video motion analysis, and force plate measurements. The proposed device reproduced the tibial-segment inclination angle with RMSE values of 0.38° and 1.58° during the stance and swing phases, respectively, with correlation coefficients of 1.00 and 0.997 and inter-repetition ICC(3,1) values above 0.999. For the vertical ground reaction force during the stance phase, an RMSE of 21.87\%BW, a correlation coefficient of 0.9501, and an inter-repetition ICC(3,1) of 0.9984 were obtained. These results indicate that the proposed platform can accurately and repeatably reproduce gait kinematics, providing preliminary evidence that a reduced-degree-of-freedom simulation-driven architecture can serve as a practical experimental platform for evaluating lower-limb prostheses.
    
\end{abstract}

\begin{IEEEkeywords}
Gait simulator, Ground reaction force, Marker-based motion analysis, Mechanical design, Transtibial prosthesis
\end{IEEEkeywords}

\section{Introduction}

Human gait is a complex biomechanical process that relies on coordinated interactions among joints, muscles, and ground reaction forces to maintain balance and stability, absorb impact, and generate forward propulsion. In individuals with lower-limb amputation, these interactions are altered by the prosthetic device, often leading to gait asymmetries, increased energy expenditure, and abnormal loading patterns that may compromise mobility and long-term musculoskeletal health. Consequently, the development and evaluation of lower-limb prostheses remain important challenges in biomechanics, rehabilitation engineering, and prosthetic design \cite{ref1,ref2,ref3,ref4,ref5}.

Conventional prosthetic evaluation relies on mechanical testing, clinical gait analysis, and experiments involving human participants. Although these methods provide valuable clinical information, they are often expensive, time-consuming, subject to inter-subject variability, and may pose safety risks during the evaluation of early-stage prototypes or active prosthetic systems. These limitations have motivated the development of biomechanical gait simulators capable of reproducing controlled, repeatable walking conditions for preclinical evaluation of assistive devices \cite{ref6,ref7}. Existing approaches include mechanical test benches, robotic gait simulators, musculoskeletal simulations, hardware-in-the-loop platforms, and prosthesis simulators worn by participants without lower-limb amputation. However, each approach presents limitations regarding their biomechanical realism, implementation complexity, computational requirements, or experimental reproducibility \cite{ref8,ref9,ref10,ref11,ref12,ref13,ref14}.

Biomechanical simulators provide an attractive alternative for evaluating prosthetic alignment, stiffness, damping, control strategies, and gait mechanics under controlled laboratory conditions. They enable systematic assessment of prosthetic components while reducing reliance on early-stage human testing and facilitating the analysis of kinematic and kinetic variables that are difficult to obtain in conventional clinical experiments \cite{ref8,ref9,ref15,ref16,ref17,ref18,ref19}.

Despite this potential, recent literature reviews indicate that most existing lower-limb prosthesis simulators have focused on transfemoral applications, with transtibial-specific platforms comparatively underrepresented \cite{ref6}. In addition, the development of gait simulators has been shown to involve an inherent trade-off between the number of controlled degrees of freedom and system cost and complexity, with high-DOF platforms requiring substantial capital investment and reduced-DOF designs facing a corresponding compromise in simulation accuracy \cite{ref20}. These observations motivate the development of a mechanically simplified, transtibial-oriented gait simulator capable of reproducing the essential kinematic and kinetic demands of gait within a reduced and cost-effective mechanical architecture.

This work presents the design, implementation, and functional assessment of a 3-degree-of-freedom (3-DOF) gait simulator for transtibial prosthesis testing. The simulator provides two translational axes (horizontal and vertical) and one rotational axis (sagittal). The proposed platform reproduces the essential kinematic and kinetic characteristics required for transtibial prosthesis evaluation using a mechanically simplified three-degree-of-freedom architecture developed through a simulation-driven design methodology integrating finite element analysis, analytical transmission sizing, and functional verification. This study provides a comprehensive description of the simulator's design and implementation processes, as well as its functional assessment using videogrammetry and ground reaction force (GRF) analysis.

\section{System Architecture}

\subsection{Mechanical Design}

The gait simulator was developed using a \textit{Simulation-Driven Design} approach that combined CAD modeling, standardized industrial components, analytical transmission sizing, and finite element analysis before manufacturing. The final architecture comprises three independently actuated coordinates: horizontal translation, vertical translation, and sagittal-plane rotation, selected to reproduce the position and orientation of the prosthetic test assembly while maintaining mechanical simplicity. The design also incorporated six limit switches for travel protection and homing, compatibility with the force platform and marker-based motion analysis, and a rigid interface for mounting transtibial prostheses.

\subsubsection{Mechanical Architecture}

The mechanical assembly was modeled in Autodesk Inventor and implemented as a modular welded-steel frame with an approximate footprint of $1153 \times 974~\mathrm{mm}$ and a total height of $1424~\mathrm{mm}$. Structural plate thicknesses ranged from 3 to 12~mm. Fig.~\ref{fig:1} shows the arrangement of the three motion modules and the principal transmission elements.

\begin{figure}[!htbp]
    \centering
    \includegraphics[width=0.9\columnwidth]
    {fig_cad_model_simulator.png}
    \caption{CAD model of the final mechanical architecture and principal motion modules.}
    \label{fig:1}
\end{figure}

The horizontal axis provides approximately $587~\mathrm{mm}$ of travel using an SFU2510 ball screw, WCS25 shafts, SC25UU linear bearing blocks, and an A6M80-750H2A1-M17 servomotor. The vertical axis provides approximately $542~\mathrm{mm}$ of travel using SFU2505 ball screws, linear guides, a roller-chain transmission, and an A6M80-750H2B1-M17 servomotor with a holding brake. Sagittal rotation ranges from $-44^{\circ}$ to $47^{\circ}$ and is generated by a 34E1K-120 closed-loop stepper motor coupled to an RYG34-G50 planetary gearbox with a 50:1 reduction ratio. The three axes converge at a $150 \times 120~\mathrm{mm}$ prosthetic mounting platform positioned approximately $752~\mathrm{mm}$ above the ground reference in the nominal configuration.

\subsubsection{Structural Verification and Transmission Selection}

Static finite element analyses were performed in ANSYS 2025 R2 for the main frame, horizontal carriage, left vertical support plate, right vertical carriage, and electrical-cabinet support. The simulations guided local reinforcement and load-transfer improvements before manufacturing. Table~\ref{tab:fea_results} summarizes the maximum deformation, equivalent von Mises stress, and static factor of safety obtained for each assembly, assuming a structural-steel yield strength of approximately $250~\mathrm{MPa}$.

\begin{table}[htbp]
    \centering
    \caption{Summary of finite element analysis results for the critical mechanical assemblies.}
    \label{tab:fea_results}
    \resizebox{\columnwidth}{!}{
    \begin{tabular}{|l|c|c|c|}
        \hline
        \textbf{Assembly} &
        \textbf{Max. def. (mm)} &
        \textbf{Max. stress (MPa)} &
        \textbf{FoS} \\
        \hline
        Main frame & 0.0659 & 36.219 & 6.9 \\
        \hline
        Horizontal carriage & 0.027 & 18.226 & 13.7 \\
        \hline
        Left vertical support plate & 0.215 & 198.060 & 1.3 \\
        \hline
        Right vertical carriage & 0.069 & 39.642 & 6.3 \\
        \hline
        Electrical-cabinet support & 0.267 & 29.094 & 8.6 \\
        \hline
    \end{tabular}
    }
\end{table}

   \begin{figure*}[htbp]
       \centering
       \includegraphics[width=0.85\linewidth]{Figura 3.jpg}
       \caption{Electrical power system and electronic control hardware: (a) block diagram of the electrical power system; (b) implemented electrical panel; (c) block diagram of the electronic control hardware; (d) fabricated electronic control board.}
       \label{fig:3}
   \end{figure*}
   
The left vertical support plate was the critical component, reaching a maximum equivalent stress of $198.06~\mathrm{MPa}$, a maximum deformation of $0.215~\mathrm{mm}$, and a minimum static factor of safety of approximately 1.3. All analyzed assemblies remained below the assumed yield strength under the considered static load cases. These results supported the release of the refined design for manufacturing; fatigue life and long-term cyclic durability were not inferred from this analysis.

For the vertical-axis chain transmission, a corrected design power of $1.05~\mathrm{kW}$ was obtained from the $0.75~\mathrm{kW}$, $3000~\mathrm{rpm}$ servomotor using a service factor of 1.4 and a 19-tooth driving sprocket. An ANSI 35 single-strand roller chain was selected as a compromise among load capacity, installation space, availability, and cost. The final transmission uses ASA 35B19 sprockets and an ASA 35-1R chain with 244 pitches, corresponding to a nominal length of $2324.1~\mathrm{mm}$.

\subsection{Electrical Power System}
The main function of the electrical power system is to supply the motor drivers and the electronic control hardware. Fig.~\ref{fig:3}(a) presents a block diagram of the power system.
   
 
    
   Single-phase AC mains power first passes through a switching and protection stage composed of rotary cam switches, thermomagnetic circuit breakers, magnetic contactors, fuses, and relays. The horizontal- and vertical-axis motor drivers are supplied from the AC mains through dedicated line filters. A 48 VDC power supply powers the sagittal-axis motor driver. In addition, a 24 VDC power supply powers the electronic control hardware and auxiliary external devices.

    The horizontal- and vertical-axis motors are driven by A6-750RS closed-loop AC servo drives, which convert single-phase AC input into three-phase synchronous output for motor operation. The sagittal-axis motor is controlled by a CL86Y closed-loop stepper driver operating from a 48 VDC power supply. Fig.~\ref{fig:3}(b) shows the implemented electrical panel.
 
    
    \subsection{Electronic Control Hardware}
    The electronic hardware was designed around an ESP32 development board. This hardware provides the interfaces required to interact with the motor drivers, the vertical-axis motor brake, and the limit switches. Fig.~\ref{fig:3}(c) shows a block diagram of this concept. An MP1584EN regulator module steps down the 24 VDC supplied by the electrical power system to 5 VDC. An ESP32 module serves as the central processing unit, executing the embedded software that generates pulse and direction signals for the motor drivers, controls the vertical-axis motor brake, manages the homing routine through the limit switches, and supervises overall system operation.
    
    Since the motor drivers employ opto-isolated pulse and direction inputs, transistor-based interface circuits were designed to provide the required drive current and ensure reliable signal transmission at pulse frequencies of up to 100~kHz.
    
    Since the vertical-axis motor incorporates a built-in electromagnetic brake to prevent unintended displacement when the system is powered down, a dedicated switching circuit was implemented to control the brake release and engagement during operation. Finally, dedicated circuits were designed to condition the limit switch signals. RC filtering and Schmitt-trigger conditioning were used for hardware debouncing and noise immunity, ensuring reliable limit-switch detection during homing and normal operation of the simulator. Fig.~\ref{fig:3}(d) shows the fabricated electronic board indicating its functional blocks.
    
    
    \subsection{Motion Control Software}
    The motion control software consists of an offline trajectory processing stage and an embedded motion control stage. In the first stage, experimental gait data recorded in CSV format are processed using a Python script that converts the trajectories into a C++ header file containing the trajectory arrays and homing parameters, which are then compiled into the embedded firmware.
    
    The embedded motion control stage is implemented on an ESP32 development board. This stage manages user interaction, coordinates three-axis motion, and ensures safe execution of the gait trajectories. Fig.~\ref{fig:4} shows the software architecture comprising both stages.
    
    User commands are received via a Bluetooth interface and processed by a command handler that supports three operating modes: manual control (direct incremental motion of each axis), calibration (axis homing via limit switch detection to establish reference positions), and trajectory execution (synchronized three-axis motion using the stored trajectory arrays).
    
    The shared motion services include a pulse generation module that generates STEP/DIR signals for all motor drivers, depending on the selected operating mode, without blocking execution. All three operating modes share this module. Safe operation is ensured by a limit-switch-handling interrupt routine that protects against motion beyond the physical travel limits. Additionally, the system controls the vertical-axis motor brake during initialization and operation to prevent unintended displacement.
    
   \begin{figure}[t!]
        \centering
        \includegraphics[width=0.7\linewidth]{fig_software_block_diagram.png}
        \caption{Block diagram of the motion control software.}
        \label{fig:4}
    \end{figure} 

\section{Functional Assessment}
A functional assessment was conducted to verify the capability of the simulator's movement relative to that of a reference subject (male, 86~kg, 1.74~m). The same instrumentation and experimental setup were used both to acquire the gait trajectories for programming the simulator's ESP32 motion control unit and to evaluate its output, ensuring full methodological consistency between the input data and the assessment conditions.

Kinematic and kinetic assessments were conducted in independent experimental sessions, corresponding to separate validation conditions (without and with a mounted prosthesis, respectively); therefore, temporal synchronization between the camera and the force platform was not required.

Kinematic data were recorded using a Sony FDR-AX700 camera at 120~fps, positioned perpendicular to the simulator's sagittal plane at a distance of 3~m and a height of 60~cm above ground level, as shown in Fig.~\ref{fig:5}. Reflective markers measuring 2.5~cm in diameter were used to identify reference points and were illuminated by a Godox Litemons LP1200R LED panel (120~W, 100\% intensity, white light mode) to ensure consistent marker visibility.

Four reflective markers were placed on the reference subject: the first at the lateral malleolus and the second 42~cm proximal to it along the transtibial segment, with its position used to calculate the horizontal and vertical trajectories. 

A third marker was placed at the midpoint of the segment formed by these two markers, and a fourth marker was aligned with the third to form a segment perpendicular to the tibial segment, allowing the calculation of the inclination angle of the tibial segment. On the simulator, two reflective markers were placed at the ends of the moving platform to track its trajectory under the same protocol. The tibial-segment inclination angle was computed from the marker coordinates using the \texttt{atan2} function, defined as positive above the horizontal reference and negative below it.

Camera calibration for pixel-to-metric conversion was performed in Kinovea using the width of the AMTI force platform (40~cm), located within the same motion plane, as the reference object to minimize angular distortion errors. Data were processed using Kinovea v.2025.2 and MATLAB R2025b. Ground reaction forces were acquired using an AMTI BP400600 force platform at 1000~Hz. Both the reference and simulator GRF signals were normalized to the subject's body weight (86~kg) and expressed as \%BW.

\begin{figure}[h!]
    \centering
    \includegraphics[width=.8\linewidth]{fig_test_setup.png}
    \caption{Experimental setup for kinematic and kinetic data acquisition.}
    \label{fig:5}
\end{figure}


\begin{figure*}[t!]
    \centering
    \includegraphics[width=0.9\linewidth]{Figura 5.jpg}
    \caption{Functional assessment of the gait simulator. (a) Tibial segment inclination angle during the stance phase. (b) Tibial segment inclination angle during the swing phase. (c) Vertical ground reaction force during the stance phase. The black line and shaded area represent the reference subject mean $\pm$ 1 SD, while the dashed red line represents the simulator mean.}
    \label{fig:6}
\end{figure*}




The trajectory data were acquired from the reference subject, whose gait cycles were recorded for the stance and swing phases. The captured trajectories were then exported as CSV files containing time, horizontal and vertical position coordinates, and the tibial segment inclination angle. For each phase, ten gait cycles were recorded and averaged to obtain the reference trajectory used to program the simulator. To characterize the intra-subject variability associated with this averaging process, the RMSE between the individual cycles and the resulting mean curve was calculated for the tibial inclination angle, yielding values of 1.41\textdegree{} during stance and 2.53\textdegree{} during swing, thereby confirming the acceptable consistency of the reference data used to program the simulator.

Ten repetitions of the simulator's programmed trajectory were recorded for each phase to assess output repeatability, independently of the ten gait cycles used to derive the reference trajectory.

Two validation conditions were evaluated: (1) kinematic fidelity without a prosthesis, comparing the tibial-segment inclination angle during the stance and swing phases independently; and (2) kinetic fidelity with a passive commercial transtibial prosthesis (42~cm prosthetic shank length, articulated prosthetic foot) mounted on the simulator, comparing the vertical ground reaction force (Fz, \%BW) during the stance phase only, since no ground contact occurs during the swing phase. Agreement between the simulator output and the reference subject trajectory was quantified using RMSE, the Pearson correlation coefficient (r), and the percentage of simulator data points within ±1 SD of the reference trajectory. In addition, the repeatability of the simulator across its ten programmed repetitions was quantified independently using the intraclass correlation coefficient ICC(3,1).

The simulator reproduced the tibial inclination angle with RMSE = 0.38°, r = 1.00, and 100\% of points within ±1 SD during the stance phase. The inter-repetition ICC(3,1) was 0.999, confirming high repeatability across the ten simulator trials (Fig.~\ref{fig:6}(a)). During the swing phase, the corresponding values were RMSE = 1.58°, r = 0.997, and 72.50\% of points within ±1 SD, with an inter-repetition ICC(3,1) of 0.999 (Fig.~\ref{fig:6}(b)). For the vertical ground reaction force, RMSE = 21.87\%BW and r = 0.9501 were obtained during the stance phase, with an inter-repetition ICC(3,1) of 0.9984, confirming consistent force output across the ten simulator repetitions (Fig.~\ref{fig:6}(c)).


\section{Discussion}
The functional assessment confirmed that the simulator accurately reproduces the reference subject's tibial-segment inclination angle during stance (RMSE = 0.38°, r = 1.00) and swing (RMSE = 1.58°, r = 0.997), which were evaluated independently, with inter-repetition ICC(3,1) values above 0.999 in both phases, confirming high repeatability of the simulator's motion across trials. A deviation was observed between approximately 60\% and 75\% of the gait cycle, where the simulator angle stabilizes near its mechanical limit while the reference subject continues towards more negative inclination values. This deviation is not attributable to a loss of fidelity, as the simulator trajectory remains aligned with the reference trajectory throughout the swing phase, but rather to the mechanical range of the sagittal rotation axis (-44° to 47°), which restricts the achievable rotation during early swing. This observation constitutes a concrete, quantifiable design constraint that can directly inform future revisions of the mechanical architecture.

For the vertical ground reaction force during the stance phase, a strong waveform correlation was obtained (r = 0.9501, ICC(3,1) = 0.9984), confirming consistent force output and accurate reproduction of the characteristic double-peak pattern of normal gait. However, the magnitude of the peak force exceeded the reference values. This overestimation can be qualitatively attributed to the added structural mass of the simulator's moving assembly and to the passive mechanical behavior of the commercial prosthesis used in this condition, rather than to inaccuracies in tracking the horizontal and vertical trajectories. The prosthesis was characterized solely by its passive design, 42~cm shank length, and articulated foot, as manufacturer specifications, including stiffness properties, were unavailable. Similarly, the added mass introduced by the simulator's moving assembly was not quantified in this study. Direct measurement of both parameters is recommended in future work to isolate their respective contributions to the observed force overestimation.

Overall, these findings indicate that the mechanical design and control architecture of the simulator can reproduce the fundamental kinematic and kinetic patterns of human gait with high fidelity and repeatability. Furthermore, the results show that the proposed reduced-degree-of-freedom architecture can reproduce the essential gait characteristics required for transtibial prosthesis evaluation.


\section{Conclusion}
This paper presents the design, implementation, and functional assessment of a three-degree-of-freedom (3-DOF) gait simulator for evaluating transtibial prostheses. The proposed platform integrates custom mechanical, electrical, electronic, and embedded software components to reproduce the horizontal, vertical, and sagittal motions of the human gait cycle.

The functional assessment demonstrated accurate reproduction of the tibial inclination angle during both the stance and swing phases. In addition, a strong waveform correlation with the reference measurements was achieved for the vertical ground reaction force during the stance phase. However, differences in peak magnitude were observed and attributed to factors not characterized in this study, such as the added mass of the simulator's moving assembly and the mechanical properties of the commercial prosthesis. The obtained RMSE and correlation coefficients confirmed the platform's fidelity, and the high inter-repetition ICC values demonstrated its repeatability.

These results indicate that the proposed simulator constitutes an accurate, repeatable, and controlled experimental platform for the engineering evaluation of transtibial prostheses prior to comprehensive biomechanical validation. Future work will focus on further assessing the platform using multiple subjects with varying anthropometric characteristics and extending it to reproduce gait patterns associated with foot pathologies. In addition, the proposed platform will be used to evaluate prototype powered transtibial prostheses equipped with closed-loop control.

\section*{Acknowledgment}
This research was funded by the Government of Peru through the National Program for Scientific Research and Advanced Studies (PROCIENCIA–CONCYTEC) under Contract No. PE501086900-2024-PROCIENCIA.


%\printbibliography
\begin{thebibliography}{99}

\bibitem{ref1}
D. A. Winter, \textit{Biomechanics and Motor Control of Human Movement}. Hoboken, NJ, USA: Wiley, 2009.

\bibitem{ref2}
\textit{Gait Analysis: Normal and Pathological Function}," J. Sports Sci. Med., vol. 9, no. 2, p. 353, Jun. 2010
\bibitem{ref3}
M. W. Whittle, \textit{Gait Analysis: An Introduction}. Oxford, UK: Butterworth-Heinemann, 2014.

\bibitem{ref4}

R. Gailey, K. Allen, J. Castles, J. Kucharik, and M. Roeder, "Review of secondary physical conditions associated with lower-limb amputation and long-term prosthesis use," \textit{Journal of Rehabilitation Research and Development}, vol. 45, no. 1, pp. 15--29, 2008, doi: 10.1682/jrrd.2006.11.0147.

\bibitem{ref5}
A. Esquenazi, "Gait analysis in lower-limb amputation and prosthetic rehabilitation," \textit{Physical Medicine and Rehabilitation Clinics of North America}, vol. 25, no. 1, pp. 153--167, Feb. 2014, doi: 10.1016/j.pmr.2013.09.006.

\bibitem{ref6}
I. Neelen, B. van der Windt, M. J. Major, and G. Smit, "State of the art of lower limb prosthesis simulators: A literature review," \textit{Wearable Technologies}, vol. 7, Art. no. e2, Mar. 2026, doi: 10.1017/wtc.2026.10038.

\bibitem{ref7}
Z. Yang, \textit{Development of a Gait Simulator for Testing Lower Limb Prostheses}, Doctor of Engineering (EngD) thesis, Department of Mechanical Engineering, University of Bath, Bath, U.K., Jul. 2020.

\bibitem{ref8}
C. Insam, L.-M. Ballat, F. Lorenz, and D. J. Rixen, "Hardware-in-the-Loop Test of a Prosthetic Foot," \textit{Applied Sciences}, vol. 11, no. 20, Art. no. 9492, 2021, doi: 10.3390/app11209492.

\bibitem{ref9}
E. De Raeve, T. Saey, L. Muraru, and L. Peeraer, "The use of a robotic gait simulator for the development of an alignment tool for lower limb prostheses," \textit{Journal of Foot and Ankle Research}, vol. 7, no. Suppl 1, Art. no. A15, Apr. 2014, doi: 10.1186/1757-1146-7-S1-A15.

\bibitem{ref10}
K. Nie, Y. Liu, X. Zhao, X. Wu, and F. Gao, "Gait Simulator for Testing and Evaluating Lower Limb Prosthesis," in \textit{Proc. IEEE/ASME International Conference on Advanced Intelligent Mechatronics (AIM)}, 2025, pp. 1--6, doi: 10.1109/AIM64088.2025.11175829.

\bibitem{ref11}
A. M. Willson, A. J. Anderson, C. A. Richburg, B. C. Muir, J. Czerniecki, K. M. Steele, and P. M. Aubin, "Full body musculoskeletal model for simulations of gait in persons with transtibial amputation," \textit{Computer Methods in Biomechanics and Biomedical Engineering}, vol. 26, no. 4, pp. 412--423, Mar. 2023, doi: 10.1080/10255842.2022.2065630.

\bibitem{ref12}
R. Carloni, R. Luinge, and V. Raveendranathan, "The gait1415+2 OpenSim musculoskeletal model of transfemoral amputees with a generic bone-anchored prosthesis," \textit{Medical Engineering \& Physics}, vol. 123, Art. no. 104091, Jan. 2024, doi: 10.1016/j.medengphy.2023.104091.

\bibitem{ref13}
M. Abdullah, A. A. Hulleck, R. Katmah, K. Khalaf, and M. El-Rich, "Multibody dynamics-based musculoskeletal modeling for gait analysis: a systematic review," \textit{Journal of NeuroEngineering and Rehabilitation}, vol. 21, no. 1, Art. no. 178, Oct. 2024, doi: 10.1186/s12984-024-01458-y.

\bibitem{ref14}
S. Kumar, V. B, S. Chandramohan, and S. Sujatha, "A novel forward-dynamics analysis and control of a Human-Robot system wearing a powered prosthetic device in a virtual environment," \textit{Results in Engineering}, vol. 29, Art. no. 109058, 2026, doi: 10.1016/j.rineng.2026.109058.

\bibitem{ref15}
E. D. Lemaire, D. Nielen, and M. A. Paquin, "Gait evaluation of a transfemoral prosthetic simulator," \textit{Archives of Physical Medicine and Rehabilitation}, vol. 81, no. 6, pp. 840--843, Jun. 2000, doi: 10.1016/S0003-9993(00)90123-0.

\bibitem{ref16}
F. Sup, A. Bohara, and M. Goldfarb, "Design and Control of a Powered Transfemoral Prosthesis," \textit{The International Journal of Robotics Research}, vol. 27, no. 2, pp. 263--273, Feb. 2008, doi: 10.1177/0278364907084588.

\bibitem{ref17}
B. Lawson, J. Mitchell, D. Truex, A. Shultz, E. Ledoux, and M. Goldfarb, "A Robotic Leg Prosthesis: Design, Control, and Implementation," \textit{IEEE Robotics \& Automation Magazine}, vol. 21, no. 4, pp. 70--81, Dec. 2014, doi: 10.1109/MRA.2014.2360303.

\bibitem{ref18}
S. Portnoy, I. Siev-Ner, N. Shabshin, A. Kristal, Z. Yizhar, and A. Gefen, "Patient-specific analyses of deep tissue loads post transtibial amputation in residual limbs of multiple prosthetic users," \textit{Journal of Biomechanics}, vol. 42, no. 16, pp. 2686--2693, Dec. 2009, doi: 10.1016/j.jbiomech.2009.08.019.

\bibitem{ref19}
M. A. McGeehan, P. G. Adamczyk, K. M. Nichols, and M. E. Hahn, "A simulation-based analysis of the effects of variable prosthesis stiffness on interface dynamics between the prosthetic socket and residual limb," \textit{Journal of Rehabilitation Assistive Technology Engineering}, vol. 9, Art. no. 20556683221111986, 2022, doi: 10.1177/20556683221111986.


\bibitem{ref20}
S. Sudeesh, M. S. Shunmugam, and S. Sujatha, "A compact and cost-effective gait simulator to advance prosthesis development with reduced reliance on human subject testing: Development, validation and application," \textit{Medical Engineering \& Physics}, vol. 134, Art. no. 104254, Dec. 2024, doi: 10.1016/j.medengphy.2024.104254.


\end{thebibliography}

\end{document}