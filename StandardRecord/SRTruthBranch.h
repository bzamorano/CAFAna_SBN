////////////////////////////////////////////////////////////////////////
// \author  Dominick Rocco
// \date    Sept. 2012
////////////////////////////////////////////////////////////////////////
#ifndef SRTRUTHBRANCH_H
#define SRTRUTHBRANCH_H

#include "StandardRecord/SRNeutrino.h"
#include "StandardRecord/SRLepton.h"

#include <vector>

namespace caf
{
  /// \brief Contains truth information for the slice for the parent
  /// neutrino/cosmic
  class SRTruthBranch
    {
    public:
      SRTruthBranch();
      ~SRTruthBranch();

      std::vector<SRNeutrino> neutrino;   ///< implemented as a vector to maintain mc.nu structure, i.e. not a pointer, but with 0 or 1 entries. 
      std::vector<SRLepton>   lepton;
      void setDefault();

    };
  
} // end namespace

#endif // SRTRUTHBRANCH_H
//////////////////////////////////////////////////////////////////////////////
