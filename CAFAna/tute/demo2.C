// Exercise the fitter
// cafe demo2.C

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

// New includes required
#include "CAFAna/Experiment/SingleSampleExperiment.h"
#include "CAFAna/Analysis/Fit.h"
#include "CAFAna/Vars/FitVarsSterile.h"

// Random numbers to fake an efficiency and resolution
#include "TRandom3.h"
TRandom3 r(0);

using namespace ana;

void demo2()
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
                          double smear = r.Gaus(1, 0.05); // Flat 5% E resolution
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
                         // 80% eff for CC, 10% for NC
                         if(isCC) return p < 0.8;
                         else return p < 0.10;
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

  // To make a fit we need to have a "data" spectrum to compare to our MC
  // Prediction object
  const Spectrum data = pred.Predict(calc).MockData(pot);

  // An Experiment object is something that can turn oscillation parameters
  // into a chisq, in this case by comparing a Prediction and a data Spectrum
  SingleSampleExperiment expt(&pred, data);

  std::cout << "At nominal parameters chisq = " << expt.ChiSq(calc) << std::endl;
  calc->SetAngle(2, 4, 0);
  std::cout << "At 3-flavour only chisq = " << expt.ChiSq(calc) << std::endl;

  // A fitter finds the minimum chisq using MINUIT by varying the list of
  // parameters given. These are FitVars from Vars/FitVars.h. They can contain
  // snippets of code to convert from the underlying angles etc to whatever
  // function you want to fit.
  Fitter fit(&expt, {&kFitDmSq41Sterile, &kFitSinSqTheta24Sterile});
  const double best_chisq = fit.Fit(calc);

  // The osc calculator is updated in-place with the best oscillation
  // parameters
  std::cout << "Best chisq is " << best_chisq << " with "
            << "dmsq41 = " << calc->GetDm(4)
            << " and sinsqth24 = " << kFitSinSqTheta24Sterile.GetValue(calc)
            << std::endl;
}
