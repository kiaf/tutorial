# ifndef AliAnalysisTaskMyTask_H
# define AliAnalysisTaskMyTask_H

#include "AliAnalysisTaskSE.h"


class AliAnalysisTaskMyTask: public AliAnalysisTaskSE
{
	private :
  	AliAODEvent*  fAOD;         //! input event
  	TList*        fOutputList;  //! output list
  	TH1F*         fHistPt;      //! dummy histogram

	public :
		// two class constructors
		AliAnalysisTaskMyTask();
		AliAnalysisTaskMyTask(const char *name);
		// class destructor
		virtual ~AliAnalysisTaskMyTask();
/*		// called once at beginning or runtime
		virtual void UserCreateOutputObjects();
		// called for each event
		virtual void UserExec(Option_t* option);
		// called at end of analysis
		virtual void Terminate(Option_t* option);
*/
		virtual void   UserCreateOutputObjects();
		virtual void   UserExec(Option_t *option);
		virtual void   Terminate(Option_t *);


		ClassDef(AliAnalysisTaskMyTask, 1) ;
};

# endif

