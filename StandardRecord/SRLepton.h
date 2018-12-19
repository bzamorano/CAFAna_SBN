////////////////////////////////////////////////////////////////////////
// \author  Bruno Zamorano
// \date    December 2018
////////////////////////////////////////////////////////////////////////
#ifndef SRLEPTON_H
#define SRLEPTON_H

namespace caf
{
  /// The SRLepton is a representation of outcoming lepton information
  class SRLepton
    {
    public:
      SRLepton();
      ~SRLepton() {  };

      int          pdg;           ///< PDG code
      double       energy;        ///< True energy [GeV]
      double       momentum;      ///< True momentum [GeV]
    };

} // end namespace

#endif // SRLEPTON_H
//////////////////////////////////////////////////////////////////////////////
