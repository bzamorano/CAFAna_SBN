////////////////////////////////////////////////////////////////////////
// \author  gsdavies@iastate.edu
// \date    February 2013
////////////////////////////////////////////////////////////////////////
#ifndef SRNEUTRINO_H
#define SRNEUTRINO_H

namespace caf
{
  /// The SRNeutrino is a representation of neutrino interaction information
  class SRNeutrino
    {
    public:
      SRNeutrino();
      ~SRNeutrino() {  };

      bool         iscc;          ///< Is CC interaction
      int          pdg;           ///< PDG code
      double       energy;        ///< True energy [GeV]
      double       inelasticityY; ///< True inelasticity
    };

} // end namespace

#endif // SRNEUTRINO_H
//////////////////////////////////////////////////////////////////////////////
