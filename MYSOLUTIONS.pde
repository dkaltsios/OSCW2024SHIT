
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

