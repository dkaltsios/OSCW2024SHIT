
// public class ShortestJobFirstScheduler extends ShortTermScheduler{

//  ShortestJobFirstScheduler(){
//    super();
//    type = SDLRTYPE.NONPREEMPTIVE;
//  }

//  public UserProcess selectUserProcess(){
//    UserProcess result = null;
//    if (myOS.suspended != null) {
//      sim.addToLog("  >Scheduler: suspended process found ("+myOS.suspended.pid+") in the ready queue");
//      result = myOS.suspended;
//      myOS.suspended = null;
//    }else if(!myOS.readyQueue.isEmpty()){
//      result = myOS.readyQueue.get(0);
//      for(int i = 1; i < myOS.readyQueue.size(); i++) {
//        if(result.codeSize > myOS.readyQueue.get(i).codeSize){
//            result = myOS.readyQueue.get(i);
//        }
//      } 
//    }
//    return result;
//  }

// }

// public class PriorityQueueScheduler extends ShortTermScheduler{

// PriorityQueueScheduler(){
//  type = SDLRTYPE.PREEMPTIVE;
//  super();
// }

// public UserProcess selectUserProcess(){
//  UserProcess result = null;
//  if (myOS.suspended != null) {
//    sim.addToLog("  >Scheduler: suspended process found ("+myOS.suspended.pid+") in the ready queue");
//    result = myOS.suspended;
//    myOS.suspended = null;
//  }else if(!myOS.readyQueue.isEmpty()){
//    result = myOS.readyQueue.get(0);
//    for(int i = 1; i < myOS.readyQueue.size(); i++) {
//      if(result.priority > myOS.readyQueue.get(i).priority){
//          result = myOS.readyQueue.get(i);
//      } else if (result.priority == myOS.readyQueue.get(i).priority) {
//          if(result.loadTime>myOS.readyQueue.get(i).loadTime){
//              result = myOS.readyQueue.get(i);
//          }
//      }
//    }  
//  }
//  return result;
// }

// }

// public class FirstFitMM extends MemoryManagerAlgorithm{

//  FirstFitMM(){
//    super();
//    type = MMANAGERTYPE.FIXED;
//  }

//  public Partition selectPartition(){
//    Partition result = null;
//    for (int i=1; i<myOS.partitionTable.size(); i++) {
//      if (myOS.partitionTable.get(i).isFree && myOS.partitionTable.get(i).size >= myOS.newProcessImage.length()) {
//        result = myOS.partitionTable.get(i);
//        result.isFree = false;
//        break;
//      }
//    }
//    if (result != null) {
//      sim.addToLog("  >Memory Manager: Partition with BA: "+result.baseAddress+" was found. Starting Process Creator");
//      myOS.raiseIRQ("createProcess");
//    } else {
//      sim.addToLog("  >Memory Manager: No partition was found. Starting Process Scheduler");
//      sim.requestFails++;
//      myOS.raiseIRQ("scheduler");
//    }
//    return result;
//  }

// }

// public class WorstFitMM extends MemoryManagerAlgorithm{

//  WorstFitMM(){
//    super();
//    type = MMANAGERTYPE.FIXED;
//  }

//  public Partition selectPartition(){
//    Partition result = null;
//    for (int i=1; i<myOS.partitionTable.size(); i++) {
//      if (myOS.partitionTable.get(i).isFree && myOS.partitionTable.get(i).size >= myOS.newProcessImage.length() || myOS.partitionTable.get(i).size > result.size) {
//        result = myOS.partitionTable.get(i);
//      }
//    }
//    if (result != null) {
//      result.isFree = false;
//      sim.addToLog("  >Memory Manager: Partition with BA: "+result.baseAddress+" was found. Starting Process Creator");
//      myOS.raiseIRQ("createProcess");
//    } else {
//      sim.addToLog("  >Memory Manager: No partition was found. Starting Process Scheduler");
//      sim.requestFails++;
//      myOS.raiseIRQ("scheduler");
//    }
//    return result;
//  }

// }

// public class CoalesceKernel extends KernelProcess{
//   private int deleteProcessBA;
//   CoalesceKernel(String name, String code, int IRQ, int ba) {
//     super(name, code, IRQ);
//     deleteProcessBA = ba;
//   }

//   public void finish() {
//     // We store previous, current and next partitions 
//     Partition currentPartition = myOS.searchPartitionTable(deleteProcessBA);
//     Partition previousPartition = null;
//     Partition nextPartition = null;

//     if (isNotFirst(currentPartition)) {
//       previousPartition = myOS.partitionTable.get(myOS.partitionTable.indexOf(currentPartition) - 1);
//     }
//     if (isNotLast(currentPartition)) {
//       nextPartition = myOS.partitionTable.get(myOS.partitionTable.indexOf(currentPartition) + 1);
//     }
//     if (isPreviousAndNextFree(previousPartition, nextPartition)) {
//       // Merge partitions previous and next with current
//       previousPartition.size += currentPartition.size + nextPartition.size;
//       myOS.partitionTable.remove(currentPartition);
//       myOS.partitionTable.remove(nextPartition);
//     } else if (isPreviousFree(previousPartition)) {
//       // Merge partitions previous with current
//       previousPartition.size += currentPartition.size;  
//       myOS.partitionTable.remove(currentPartition);  
//     } else if (isNextFree(nextPartition)) {
//       // Merge partitions next with current
//       currentPartition.size += nextPartition.size;
//       myOS.partitionTable.remove(nextPartition);
//     }
//   }

//   private boolean isNotFirst(Partition currentPartition) {
//     return myOS.partitionTable.indexOf(currentPartition) > 0;
//   }

//   private boolean isNotLast(Partition currentPartition) {
//     return myOS.partitionTable.indexOf(currentPartition) < myOS.partitionTable.size() - 1;
//   }

//   private boolean isPreviousAndNextFree(Partition previousPartition, Partition nextPartition) {
//     return isPreviousFree(previousPartition) && isNextFree(nextPartition);
//   }

//   private boolean isPreviousFree(Partition previousPartition) {
//     return previousPartition != null && previousPartition.isFree;
//   }

//   private boolean isNextFree(Partition nextPartition) {
//     return nextPartition != null && nextPartition.isFree;
//   }
// }