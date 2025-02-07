# Cross-talker Generalization based on SSL-ASR

## **Overview**
This repository implements an **ASR-based exemplar model** to investigate how human listeners adapt to and generalize non-native (L2) accented speech. Inspired by exemplar theory, we leverage **self-supervised speech representations** to model perceptual similarity between talkers and predict human transcription accuracy.

This work under review of CogSci 2025:
Z Jin, Y Zhu, TF Jaeger. ['Latent speech representations learned through self-supervised learning predict listeners' generalization of adaptation across talkers'](https://cognitivesciencesociety.org/cogsci-2025/) 


Our approach extends previous work by:
- **Utilizing ASR-derived latent representations** to quantify talker similarity.
- **Applying dynamic time warping (DTW) and t-SNE** for perceptual trajectory alignment.
- **Predicting listener adaptation using mixed-effects logistic regression**.

## **Background**
Human listeners adapt quickly to novel talkers and accents, yet the underlying mechanisms remain unclear. Exemplar theory suggests that speech perception relies on rich, stored perceptual traces. However, past research has focused on **highly controlled phonetic contrasts**, leaving open the question of whether **these mechanisms also explain generalization in natural speech.**

This project **bridges that gap** by:
- Using **self-supervised ASR models (HuBERT)** to derive a **latent perceptual space**.
- Measuring **similarity between exposure and test talkers** via **word-level feature distances**.
- Comparing model predictions to **human transcription data from Xie et al. (2021)**.

## **Key Features**
- **ASR-Based Perceptual Space**  
  - Extracts **512-dimensional embeddings** from HuBERT’s CNN/Transformer layers.
  - Applies **t-SNE** to project high-dimensional representations into **3D latent space**.

- **Word-Level Perceptual Similarity**  
  - Aligns speech trajectories via **DTW**.
  - Computes similarity using an **exponential distance function**.

- **Generalization Prediction**  
  - Models listener adaptation using **mixed-effects logistic regression**.
  - Evaluates the influence of **talker exposure conditions** on generalization.

## **Methodology**
### 1. **Data**  
We use **Experiment 1a from [Xie et al. (2021)](https://pubmed.ncbi.nlm.nih.gov/34370501/)** ([OSF link](https://osf.io/brwx5/)), where 320 participants transcribed sentences from University ofNorthwestern [**Archive of L1 and L2 Scripted and Spontaneous Transcripts And Recordings'**](https://speechbox.linguistics.northwestern.edu/allsstar) Mandarin-accented English talkers (Bradlow, A. R. (n.d.) ALLSSTAR). Listeners were exposed to:
- **Control Condition:** Native (L1) English talkers.
- **Multi-Talker Condition:** Different L2 talkers.
- **Single-Talker Condition:** One repeated L2 talker.
- **Talker-Specific Condition:** The same L2 talker as in the test phase.

### 2. **Feature Extraction**  
- Project all speech recordings into **HuBERT’s latent space**.
- Reduce dimensionality using **t-SNE (3D representation)**.

### 3. **Similarity Computation**  
- Align **keyword trajectories** across talkers using **DTW**.
- Compute perceptual similarity using:

$$
  dist(i,j) = \sqrt[\tau]{\sum_m w_m|v_{m,i}-v_{m,j}|^\tau}
$$

$$
  \text{similarity} = \exp\left(\frac{-D(w_x, w_y)^k}{|\pi_{\min}|}\right)
 $$

  where $ D(w_x, w_y) $ is the DTW-based distance.

### 4. **Modeling Human Perception**  
- Fit **mixed-effects logistic regression** to predict listener transcription accuracy.
- Compare the influence of **talker similarity vs. exposure condition**.

## **Results**
- **Similarity-based inference significantly predicts transcription accuracy**.
- **Transformer-derived features outperform CNN-based features**.
- **Generalization effects align with human experimental results**.
