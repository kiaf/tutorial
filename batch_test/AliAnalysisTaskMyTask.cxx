#include "TROOT.h"
#include "TList.h"
#include "TChain.h"
#include "TH1F.h"
#include "AliAnalysisTaskMyTask.h"
#include "AliAnalysisTaskSE.h"
#include "AliAODEvent.h"

ClassImp(AliAnalysisTaskMyTask);

AliAnalysisTaskMyTask::AliAnalysisTaskMyTask(): 
	AliAnalysisTaskSE(), 
	fAOD(0), 
	fOutputList(0), 
	fHistPt(0)
{
  // ROOT IO constructor , don't allocate memory here !
}

AliAnalysisTaskMyTask::AliAnalysisTaskMyTask(const char* name): 
		AliAnalysisTaskSE(name), 
		fAOD(0), 
		fOutputList(0), 
		fHistPt(0)
{
  DefineInput(0, TChain::Class()) ;
	DefineOutput(1, TList::Class()) ;
}

AliAnalysisTaskMyTask::~AliAnalysisTaskMyTask() {
	//	if(fOutputList) delete fOutputList; 
}
//virtual void AliAnalysisTaskMyTask::UserCreateOutputObjects()
void AliAnalysisTaskMyTask::UserCreateOutputObjects()
{
  // create a new TList that OWNS its objects
  fOutputList = new TList() ;
  fOutputList -> SetOwner(kTRUE) ;

  // create our histo and add it to the list
  fHistPt = new TH1F(" fHistPt ", " fHistPt ", 100, 0, 100) ;
  fOutputList -> Add(fHistPt) ;

  // add the list to our output file
  PostData(1, fOutputList) ; // recall 1 from constructor
}

void AliAnalysisTaskMyTask::UserExec(Option_t *)
//virtual void AliAnalysisTaskMyTask::UserExec(Option_t *)
{
  // get an event from the analysis manager
  AliAODEvent *fAOD = dynamic_cast <AliAODEvent *> (InputEvent());

  // check if there actually is an event
  if (!fAOD) return ;
  // let ’s loop over the trakcs and fill our histogram
  Int_t iTracks (fAOD -> GetNumberOfTracks());
  for (Int_t i(0) ; i < iTracks ; i++) {
    // loop over all the tracks
    AliAODTrack * track = static_cast <AliAODTrack *> (fAOD -> GetTrack(i));
    if (!track) continue ;
    // fill our histogram
    fHistPt -> Fill(track -> Pt());
  }
  // and save the data gathered in this iteration
  PostData(1, fOutputList);
}
//____________________________________________________________
 void AliAnalysisTaskMyTask::Terminate(Option_t *){
 //
  // Terminate not implemented at the moment
  //
}
