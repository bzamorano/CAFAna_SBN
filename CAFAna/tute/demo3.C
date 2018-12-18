// Make a simple contour
// cafe demo3.C

#include "CAFAna/Core/SpectrumLoader.h"
#include "CAFAna/Core/Spectrum.h"
#include "CAFAna/Core/Binning.h"
#include "CAFAna/Core/Var.h"
#include "CAFAna/Cuts/TruthCuts.h"
#include "CAFAna/Prediction/PredictionNoExtrap.h"
#include "CAFAna/Analysis/Calcs.h"
#include "OscLib/func/OscCalculatorSterile.h"
#include "StandardRecord/StandardRecord.h"
#include "TCanvas.h"
#include "TH1.h"
#include "CAFAna/Experiment/SingleSampleExperiment.h"
#include "CAFAna/Vars/FitVarsSterile.h"

// New includes
#include "CAFAna/Analysis/Surface.h"
#include "CAFAna/Experiment/MultiExperiment.h"

// Random numbers to fake an efficiency and resolution
#include "TRandom3.h"
TRandom3 r(0);

#include "TMarker.h"

using namespace ana;

void demo3()
{
  // See demo0.C for explanation of these repeated parts
  const std::string fnameBeam = "/sbnd/app/users/bzamoran/sbncode-v07_11_00/output_largesample_nu_ExampleAnalysis_ExampleSelection.root";
  const std::string fnameSwap = "/sbnd/app/users/bzamoran/sbncode-v07_11_00/output_largesample_oscnue_ExampleAnalysis_ExampleSelection.root";

  // Source of events
  SpectrumLoader loaderBeam(fnameBeam);
  SpectrumLoader loaderSwap(fnameSwap);

  const Var kRecoEnergy({}, // ToDo: smear with some resolution
                        [](const caf::StandardRecord* sr)
                        {
                          double fE = sr->sbn.truth.neutrino[0].energy;
                          double smear = r.Gaus(1, 0.03); // Flat 3% E resolution
                          return fE;
                        });

  const Binning binsEnergy = Binning::Simple(50, 0, 5);
  const HistAxis axEnergy("Fake reconsturcted energy (GeV)", binsEnergy, kRecoEnergy);

  // Fake POT: we need to sort this out in the files first
  const double pot = 6.e20;

  const Cut kSelectionCut({},
                       [](const caf::StandardRecord* sr)
                       {
                         bool isCC = sr->sbn.truth.neutrino[0].iscc;
                         double p = r.Uniform();
                         // 90% eff for CC, 15% for NC
                         if(isCC) return p < 0.9;
                         else return p < 0.15;
                       });

  PredictionNoExtrap pred(loaderBeam, loaderSwap, kNullLoader,
                          axEnergy, kSelectionCut);


  loaderBeam.Go();
  loaderSwap.Go();

  // Calculator
  osc::OscCalculatorSterile* calc = DefaultSterileCalc(4);
  calc->SetL(0.11); // SBND only, temporary
  calc->SetAngle(2, 4, 0.55);
  calc->SetDm(4, 1); // Some dummy values

  TMarker* trueValues = new TMarker(pow(TMath::Sin(2*calc->GetAngle(2,4)),2), calc->GetDm(4), kFullCircle);
  trueValues->SetMarkerColor(kRed);

  // To make a fit we need to have a "data" spectrum to compare to our MC
  // Prediction object
  const Spectrum data = pred.Predict(calc).FakeData(pot);

  SingleSampleExperiment expt(&pred, data);

  // A Surface evaluates the experiment's chisq across a grid
  Surface surf(&expt, calc,
               &kFitSinSq2Theta24Sterile, 50, 0, 1,
               &kFitDmSq41Sterile, 75, 0.5, 3);


  TCanvas* c1 = new TCanvas("c1");
  //c1->SetLogy();
  c1->SetLeftMargin(0.12);
  c1->SetBottomMargin(0.15);
  //surf.Draw();
  surf.DrawBestFit(kBlue);
  trueValues->Draw();


  // In a full Feldman-Cousins analysis you need to provide a critical value
  // surface to be able to draw a contour. But we provide these helper
  // functions to use the gaussian up-values.
  TH2* crit1sig = Gaussian68Percent2D(surf);
  TH2* crit2sig = Gaussian2Sigma2D(surf);

  surf.DrawContour(crit1sig, 7, kBlue);
  surf.DrawContour(crit2sig, kSolid, kBlue);

  c1->SaveAs("demo3_plot1.pdf");

}
