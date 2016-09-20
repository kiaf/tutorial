#!/bin/bash
condor_slot=40
nfile=10
merge=1	#0=nomerge, 1=merge

work_dir=`date +%y%m%d%H%M%S`
run_macro="runAnalysis.C"
data_file="sim_LHC13d3_195675_AOD159.txt"
input_files="AddMyTask.C,AliAnalysisTaskMyTask.cxx,AliAnalysisTaskMyTask.h"
out_file="AnalysisResults.root"

main_dir=`pwd`
source $HOME/.alice_env/alice_env.conf

AliPhysicsVersion=$ALIPHYSICS_VERSION
AliRootVersion=$ALICE_ROOT_VERSION

if [ -z $ALIPHYSICS_VERSION ] ; then
       root_version="AliRoot::${AliRootVersion}"
else
       root_version="AliPhysics::${AliPhysicsVersion}"
fi

mkdir ${work_dir}
mkdir ${work_dir}/logs
mkdir ${work_dir}/macro

cp /pool/macro/job_wrap.sh /pool/macro/merge.sh /pool/macro/nomerge.sh  ${work_dir}/macro/.

cat <<EOF > ${work_dir}/macro/merge.C
void merge(){
  //load the required aliroot libraries
  //gSystem->Load("libCore.so");
  //gSystem->Load("libTree.so");
  //gSystem->Load("libGeom.so");
  //gSystem->Load("libVMC.so");
  //gSystem->Load("libPhysics.so");
  //gSystem->Load("libSTEERBase");
  //gSystem->Load("libESD");
  //gSystem->Load("libAOD");
  //gSystem->Load("libANALYSIS");
  //gSystem->Load("libANALYSISalice");
  //gSystem->Load("libCORRFW.so");  //load correction framework library

  //gSystem->Load("libPWGmuon.so");
  //gSystem->Load("libPWGHFbase.so");

  //compile online the task class
   //gSystem->SetIncludePath("-I. -I$ROOTSYS/include -I$ROOTSYS/net/alien/inc");
   //gSystem->SetIncludePath("-I. -I$ALICE_ROOT/include -I$ALICE_ROOT/PWG/muon -I$ALICE_ROOT/MUON");

TFileMerger m$l;

m.OutputFile("${main_dir}/merge_${out_file}");
EOF

i=1
k=1
while read data_list
do
if [ $i -eq 1 ] ; then
if [ ${#k} -eq 4 ] ; then
num=$k ;fi
if [ ${#k} -eq 3 ] ; then
num=0$k ;fi
if [ ${#k} -eq 2 ] ; then
num=00$k ;fi
if [ ${#k} -eq 1 ] ; then
num=000$k ;fi
mkdir ${work_dir}/${num}

cat <<EOF > ${work_dir}/${num}/jdl${num}
Universe                = vanilla
Executable              = ${work_dir}/macro/job_wrap.sh
Log                     = ${work_dir}/logs/${num}.log
Output                  = ${work_dir}/logs/${num}.out
Error                   = ${work_dir}/logs/${num}.error
transfer_input_files    = ${run_macro},${input_files},${work_dir}/${num}/${num}data.txt

should_transfer_files   = YES
when_to_transfer_output = ON_EXIT
arguments               = "${root_version} ${run_macro} ${num}data.txt"
output_destination = file://${main_dir}/${work_dir}/${num}
Queue
EOF

echo "Job $num ${work_dir}/${num}/jdl$num" >> ${work_dir}/macro/condor.job.list
echo "$num \ " >> ${work_dir}/macro/condor.parents.list

cat <<EOF >> ${work_dir}/macro/merge.C
m.AddFile("${main_dir}/${work_dir}/${num}/${out_file}");
EOF
fi
k=$((k + 1))
echo ${data_list} >> ${work_dir}/${num}/${num}data.txt
i=$((i + 1))
if [ $i -eq $nfile ] ; then
i=1 ; fi
done < $data_file

cat ${work_dir}/macro/condor.job.list >> ${work_dir}/macro/condor.dag
echo "Job MERGE ${work_dir}/macro/merge.jdl" >> ${work_dir}/macro/condor.dag
echo "PARENT \ " >> ${work_dir}/macro/condor.dag
cat ${work_dir}/macro/condor.parents.list >> ${work_dir}/macro/condor.dag
echo "CHILD MERGE" >> ${work_dir}/macro/condor.dag
cat <<EOF >> ${work_dir}/macro/merge.C
m.Merge();
}
EOF
if [ $merge -eq 1 ] ; then
cat <<EOF > ${work_dir}/macro/merge.jdl
Universe   		= vanilla
Executable 		= ${work_dir}/macro/merge.sh
Log        		= ${work_dir}/logs/merge.log
Output   	 	= ${work_dir}/logs/merge.out
Error      		= ${work_dir}/logs/merge.error
transfer_input_files    = ${work_dir}/macro/merge.C

should_transfer_files   = YES
when_to_transfer_output = ON_EXIT
arguments               = "${root_version}"
Queue
EOF
else
cat <<EOF > ${work_dir}/macro/merge.jdl
Universe                = vanilla
Executable              = ${work_dir}/macro/nomerge.sh
Log                     = ${work_dir}/logs/merge.log
Output                  = ${work_dir}/logs/merge.out
Error                   = ${work_dir}/logs/merge.error
transfer_input_files    = ${work_dir}/macro/merge.C

should_transfer_files   = YES
when_to_transfer_output = ON_EXIT
arguments               = "${root_version}"
Queue
EOF
fi
condor_submit_dag -force -maxjobs $condor_slot ${work_dir}/macro/condor.dag
