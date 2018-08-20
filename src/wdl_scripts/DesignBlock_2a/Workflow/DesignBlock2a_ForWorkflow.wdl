#########################################################################################################
####              This WDL script is used to run the  steps as individual modules              ##
##########################################################################################################

import "src/wdl_scripts/DesignBlock_2a/Tasks/realignment.wdl" as REALIGNMENT
import "src/wdl_scripts/DesignBlock_2a/Tasks/bqsr.wdl" as BQSR
import "src/wdl_scripts/DesignBlock_2a/Tasks/haplotyper.wdl" as HAPLOTYPER
import "src/wdl_scripts/DesignBlock_2a/Tasks/vqsr.wdl" as VQSR

workflow CallBlock2aTasks {

   File GlobalAlignedSortedDedupedBam
   File GlobalAlignedSortedDedupedBamBai

############## BOILERPLATE FOR DESIGN BLOCK 2a ########################################

   String SampleName                                   

   File Ref                            
   File RefFai                                         

   String RealignmentKnownSites                                     
   String BQSRKnownSites                                     
   File MillsVCF
   File MillsVCFIdx
   File DBSNP
   File DBSNPIdx

#   File KnownSitesIdx                                  
  
   String SentieonLicense                              
   String Sentieon                                     
   String SentieonThreads                                      

   String DebugMode                                   

   File RealignmentScript                              
   File BqsrScript
   File HaplotyperScript
   File VqsrScript

######################################################################################
   
   call REALIGNMENT.realignmentTask  as realign {
      input:
         InputAlignedSortedDedupedBam = GlobalAlignedSortedDedupedBam,
         InputAlignedSortedDedupedBamBai = GlobalAlignedSortedDedupedBamBai,
         SampleName = SampleName,
         Ref = Ref,
         RefFai = RefFai,
         RealignmentKnownSites = RealignmentKnownSites,
#         KnownSitesIdx = KnownSitesIdx,
         SentieonThreads = SentieonThreads,
         SentieonLicense = SentieonLicense,
         Sentieon = Sentieon,
         DebugMode = DebugMode,
         RealignmentScript = RealignmentScript
   }
   
   call BQSR.bqsrTask as bqsr {
      input:
         InputAlignedSortedDedupedRealignedBam = realign.AlignedSortedDedupedRealignedBam,
         InputAlignedSortedDedupedRealignedBamBai = realign.AlignedSortedDedupedRealignedBamBai,
         SampleName = SampleName,
         Ref = Ref,
         RefFai = RefFai,
         BQSRKnownSites = BQSRKnownSites,
 #        KnownSitesIdx = KnownSitesIdx,
         SentieonThreads = SentieonThreads,
         SentieonLicense = SentieonLicense,
         Sentieon = Sentieon,
         DebugMode = DebugMode,
         BqsrScript = BqsrScript
   }


   call HAPLOTYPER.variantCallingTask as haplotype { 
      input:
         InputAlignedSortedDedupedRealignedBam = realign.AlignedSortedDedupedRealignedBam,
         InputAlignedSortedDedupedRealignedBamBai = realign.AlignedSortedDedupedRealignedBamBai,
         RecalTable = bqsr.RecalTable,
         SampleName = SampleName,
         Ref = Ref,
         RefFai = RefFai,
         DBSNP = DBSNP,
         DBSNPIdx = DBSNPIdx,
         SentieonThreads = SentieonThreads,
         SentieonLicense = SentieonLicense,
         Sentieon = Sentieon,
         DebugMode = DebugMode,
         HaplotyperScript = HaplotyperScript
   }

   call VQSR.vqsrTask as vqsr {
      input:
         InputVCF = haplotype.VCF,
         InputVCFIdx = haplotype.VcfIdx,
         SampleName = SampleName,
         Ref = Ref,
         RefFai = RefFai,
         HapMapVCF = HapMapVCF,
         HapMapVCFIdx = HapMapVCFIdx,
         OmniVCF = OmniVCF,
         OmniVCFIdx = OmniVCFIdx,
         ThousandGVCF = ThousandGVCF,
         ThousandGVCFIdx = ThousandGVCFIdx,
         MillsVCF = MillsVCF,
         MillsVCFIdx = MillsVCFIdx,
         DBSNP = DBSNP,
         DBSNPIdx = DBSNPIdx,
         SentieonThreads = SentieonThreads,
         SentieonLicense = SentieonLicense,
         Sentieon = Sentieon,
         DebugMode = DebugMode,
         VqsrScript = VqsrScript
   }

   
}