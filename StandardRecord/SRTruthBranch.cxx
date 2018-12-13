////////////////////////////////////////////////////////////////////////
// \brief   An SRTruthBranch contains vectors of SRTruth.  
//          It is intended for use in the Common Analysis File ROOT trees.
//
// \author  Dominick Rocoo
// \date    November 2012
////////////////////////////////////////////////////////////////////////

#include "StandardRecord/SRTruthBranch.h"


namespace caf
{
  
  SRTruthBranch::SRTruthBranch():
  neutrino()
  {  }
  
  SRTruthBranch::~SRTruthBranch() {}
  
  
  void SRTruthBranch::setDefault()
  {
  }
  
  
} // end namespace caf
////////////////////////////////////////////////////////////////////////
