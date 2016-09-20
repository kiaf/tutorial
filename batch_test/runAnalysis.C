void runAnalysis(const char *dataset) {
  // header location
  gROOT -> ProcessLine(".include $ROOTSYS/include") ;
  gROOT -> ProcessLine(".include $ALICE_ROOT/include") ;
  gROOT -> ProcessLine(".include $ALICE_PHYSICS/include") ;
  //gSystem->Load("libANALYSISalice");

	// create the analysis manager
  AliAnalysisManager *mgr = new AliAnalysisManager("AnalysisMyTask");
	gROOT->LoadMacro("$ALICE_ROOT/ANALYSIS/macros/train/AddAODHandler.C");
  AliAODInputHandler *aodH = AddAODHandler();
//  mgr -> SetInputEventHandler(aodH);
  // +; compile the class ( locally ) g; debug
  gROOT -> LoadMacro("AliAnalysisTaskMyTask.cxx++g");
  // load the addtask macro
  gROOT -> LoadMacro("AddMyTask.C");
  // create an instance of your analysis task
  AliAnalysisTaskMyTask *task = AddMyTask();
	// if you want to run locally , we need to define some input
  
	if(!mgr->InitAnalysis()) printf("asdfasdf");
	
	TChain *chain = new TChain("aodTree");
  	
	//for list of input files
	gROOT->LoadMacro("$ALICE_PHYSICS/PWG/EMCAL/macros/CreateAODChain.C");
	chain = CreateAODChain(dataset);
	
  mgr -> StartAnalysis("local",chain);
}
