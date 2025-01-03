import java.util.Collections;

// * Schedulers
// Shortest Job First Scheduler
// Pick the process with the shortest burst time
public class ShortestJobFirstScheduler extends ShortTermScheduler{
    
    ShortestJobFirstScheduler() {
        super();
        type = SDLRTYPE.NONPREEMPTIVE;
    }
    
    public UserProcess selectUserProcess() {
        UserProcess result = null;
        if (!myOS.readyQueue.isEmpty()) {
            result = myOS.readyQueue.get(0);
            for (int i = 1; i < myOS.readyQueue.size(); i++) {
                if (result.codeSize > myOS.readyQueue.get(i).codeSize) {
                    result = myOS.readyQueue.get(i);
                }
            }
        }
        return result;
    }
    
}

///////////////////////////////////////////////////////////////
// Priority Queue Scheduler
// Pick the first process with the highest priority
public class PriorityQueueScheduler extends ShortTermScheduler{
    
    PriorityQueueScheduler() {
        super();
        type = SDLRTYPE.PREEMPTIVE;
    }
    
    public UserProcess selectUserProcess() {
        UserProcess result = null;
        if (!myOS.readyQueue.isEmpty()) {
            result = myOS.readyQueue.get(0);
            for (int i = 1; i < myOS.readyQueue.size(); i++) {
                if (result.priority > myOS.readyQueue.get(i).priority) {
                    result = myOS.readyQueue.get(i);
                } else if (result.priority == myOS.readyQueue.get(i).priority) {
                    if (result.programCounter > myOS.readyQueue.get(i).programCounter) {
                        result = myOS.readyQueue.get(i);
                    }
                }
            } 
        }
        return result;
    }
    
}

///////////////////////////////////////////////////////////////
// First Come First Serve Scheduler
// Pick the first process in the ready queue
public class FCFScheduler extends ShortTermScheduler{
    FCFScheduler() {
        super();
        //NONPREMPTIVE HAS ERRORIN SIMULATOR
        type = SDLRTYPE.PREEMPTIVE;
    }
    
    public UserProcess selectUserProcess() {
        UserProcess result = null;
        if (myOS.suspended != null) {
            sim.addToLog("  >Scheduler: suspended process found (" + myOS.suspended.pid + ") in the ready queue");
            result = myOS.suspended;
            myOS.suspended = null;
        } else if (!myOS.readyQueue.isEmpty()) {
            result = myOS.readyQueue.get(0); 
        }
        return result;
    }
}

///////////////////////////////////////////////////////////////
// Shortest Remaining Time Next Scheduler
// Pick the process with the shortest remaining burst time
public class SRTNScheduler extends ShortTermScheduler{
    
    SRTNScheduler() {
        super();
        type = SDLRTYPE.PREEMPTIVE;
    }
    
    public UserProcess selectUserProcess() {
        UserProcess result = null;
        if (myOS.suspended != null) {
            sim.addToLog("  >Scheduler: suspended process found (" + myOS.suspended.pid + ") in the ready queue");
            result = myOS.suspended;
            myOS.suspended = null;
        } else if (!myOS.readyQueue.isEmpty()) {
            result = myOS.readyQueue.get(0);
            for (int i = 1; i < myOS.readyQueue.size(); i++) {
                if ((result.codeSize - result.programCounter) > (myOS.readyQueue.get(i).codeSize - myOS.readyQueue.get(i).programCounter)) {
                    result = myOS.readyQueue.get(i);
                }
            }
        }
        return result;
    }
}

///////////////////////////////////////////////////////////////
// *Memory Managers
// First Fit Memory Manager
// Pick the first partition that fits the process size
public class FirstFitMM extends MemoryManagerAlgorithm{
  
  FirstFitMM() {
    super();
    type = MMANAGERTYPE.VARIABLE;
  }
  
  public Partition selectPartition() {
    Partition result = null;
    for (int i = 1; i < myOS.partitionTable.size(); i++) {
      if (myOS.partitionTable.get(i).isFree && myOS.partitionTable.get(i).size >= myOS.newProcessImage.length()) {
        result = myOS.partitionTable.get(i);
        result.isFree = false;
        break;
      }
    }
    if (result != null) {
      if (result.size > myOS.newProcessImage.length()) splitPartition(result, myOS.newProcessImage.length());
      sim.addToLog("  >Memory Manager : Partition with BA : " + result.baseAddress + " was found.Starting Process Creator");
      myOS.raiseIRQ("createProcess");
    } else{
      sim.addToLog("  >Memory Manager: No partition was found. Starting Compact Kernel");
      sim.requestFails++;
      // Moved to compact kernel
      // myOS.raiseIRQ("scheduler");
      myOS.raiseIRQ("compact");
    }
    return result;
  }
  
}

///////////////////////////////////////////////////////////////
// Best Fit Memory Manager
// Pick the biggest partition that fits the process size
public class WorstFitMM extends MemoryManagerAlgorithm{
  
  WorstFitMM() {
    super();
    type = MMANAGERTYPE.VARIABLE;
  }
  
  public Partition selectPartition() {
    Partition result = null;
    int maxSize = 0;
    for (int i = 0; i < myOS.partitionTable.size(); i++) {
      if (myOS.partitionTable.get(i).isFree && maxSize < myOS.partitionTable.get(i).size && myOS.partitionTable.get(i).size >= myOS.newProcessImage.length()) {
        result = myOS.partitionTable.get(i);
        maxSize = result.size;
      }
    }
    if (result != null) {
      if (result.size > myOS.newProcessImage.length()) splitPartition(result, myOS.newProcessImage.length());
      result.isFree = false;
      sim.addToLog("  >Memory Manager: Partition with BA: " + result.baseAddress + " was found. Starting Process Creator");
      myOS.raiseIRQ("createProcess");
    } else{
      sim.addToLog("  >Memory Manager: No partition was found. Starting Compact Kernel");
      sim.requestFails++;
      // Moved to compact kernel
      // myOS.raiseIRQ("scheduler");
      myOS.raiseIRQ("compact");
    }
    return result;
  }
}

// Split the selected partition into two partitions with the process size and the remaining size
private void splitPartition(Partition partition, int processSize) {
    int partitionBSize = partition.size - processSize;
    int partitionABA = partition.baseAddress;
    int partitionBBA = partitionABA + processSize;
    int partitionId = myOS.partitionTable.indexOf(partition);
    Partition partitionA = new Partition(partitionABA, processSize);
    partitionA.isFree = false;
    Partition partitionB = new Partition(partitionBBA, partitionBSize);
    myOS.partitionTable.remove(partition);
    myOS.partitionTable.add(partitionId, partitionA);
    myOS.partitionTable.add(partitionId + 1, partitionB);
}

///////////////////////////////////////////////////////////////
// * Kernel Processes
// Coalesce Kernel
// Check if there are adjacentfree partitions to merge with the cleared partition
public class CoalesceKernel extends KernelProcess{
    CoalesceKernel(String name, String code, int IRQ) {
        super(name, code, IRQ);
    }
    
    public void finish() {
        Partition deletePartition = myOS.searchPartitionTable(myOS.deleteProcess.baseAddress);
        int deletePartitionIndex = myOS.partitionTable.indexOf(deletePartition);
        
        if (isNotFirst(deletePartitionIndex)) {
            if (isNotLast(deletePartitionIndex)) {
                if (isPreviousAndNextFree(deletePartitionIndex)) {
                    coalescePreviousAndNext(deletePartitionIndex);
                    sim.addToLog("  >Coalesce: Merged previous, current, and next partitions.");
                } else if (isPreviousFree(deletePartitionIndex)) {
                    coalescePrevious(deletePartitionIndex);
                    sim.addToLog("  >Coalesce : Merged previous partition with current.");
                } else if (isNextFree(deletePartitionIndex)) {
                    coalesceNext(deletePartitionIndex);
                    sim.addToLog("  >Coalesce: Merged next partition with current.");
                } else {
                    sim.addToLog("  >Coalesce : No adjacent free partitions to merge.");
                }
            } else {
                if (isPreviousFree(deletePartitionIndex)) {
                    coalescePrevious(deletePartitionIndex);
                    sim.addToLog("  >Coalesce: Merged previous partition with current.");
                } else {
                    sim.addToLog("  >Coalesce : No adjacentfree partitions to merge.");
                }
            }
        } else if (isNotLast(deletePartitionIndex)) {
            if (isNextFree(deletePartitionIndex)) {
                coalesceNext(deletePartitionIndex);
                sim.addToLog("  >Coalesce : Merged next partition with current.");
            } else {
                sim.addToLog("  >Coalesce : No adjacent free partitions to merge.");
            }
        } else {
            sim.addToLog("  >Coalesce : No adjacent free partitions to merge.");
        }
        
        sim.addToLog("  >Coalesce: Finished coalescing partition " + deletePartition.baseAddress + ".Starting Process Scheduler");
        myOS.startKernelProcess("scheduler");
        this.state = STATE.READY;
    } 
    //Position check
    //Check if partition is not first
    private boolean isNotFirst(int currentPartitionIndex) {
        return currentPartitionIndex > 0;
    }
    //Check if partition is not last
    private boolean isNotLast(int currentPartitionIndex) {
        return currentPartitionIndex < myOS.partitionTable.size() - 1;
    }
    
    //Free check
    //Check if previous and next partitions are free
    private boolean isPreviousAndNextFree(int currentPartitionIndex) {
        return isPreviousFree(currentPartitionIndex) && isNextFree(currentPartitionIndex);
    }
    //Check if previous partition is free
    private boolean isPreviousFree(int currentPartitionIndex) {
        Partition previousPartition = myOS.partitionTable.get(currentPartitionIndex - 1);
        return previousPartition.isFree;
    }
    //Check if next partition is free
    private boolean isNextFree(int currentPartitionIndex) {
        Partition nextPartition = myOS.partitionTable.get(currentPartitionIndex + 1);
        return nextPartition.isFree;
    } 
    
    //Coalesce
    //Merge previous, current, and next partitions
    private void coalescePreviousAndNext(int currentPartitionIndex) {
        //Merge partitions previous and next with current
        Partition currentPartition = myOS.partitionTable.get(currentPartitionIndex);
        Partition previousPartition = myOS.partitionTable.get(currentPartitionIndex - 1);
        Partition nextPartition = myOS.partitionTable.get(currentPartitionIndex + 1);
        previousPartition.size += currentPartition.size + nextPartition.size;
        myOS.partitionTable.remove(currentPartition);
        myOS.partitionTable.remove(nextPartition);
    }
    //Merge previous with current
    private void coalescePrevious(int currentPartitionIndex) {
        //Merge partitions previous with current
        Partition currentPartition = myOS.partitionTable.get(currentPartitionIndex);
        Partition previousPartition = myOS.partitionTable.get(currentPartitionIndex - 1);
        previousPartition.size += currentPartition.size;
        myOS.partitionTable.remove(currentPartition);
    }
    //Merge next with current
    private void coalesceNext(int currentPartitionIndex) {
        //Merge partitions next with current
        Partition currentPartition = myOS.partitionTable.get(currentPartitionIndex);
        Partition nextPartition = myOS.partitionTable.get(currentPartitionIndex + 1);
        currentPartition.size += nextPartition.size;
        myOS.partitionTable.remove(nextPartition);
    }
}

///////////////////////////////////////////////////////////////
// Compact Kernel
public class CompactKernel extends KernelProcess{
  CompactKernel(String name, String code, int IRQ) {
    super(name, code, IRQ);
  }
  
  public void finish() {
    ArrayList<Partition> partitionsToRemove = new ArrayList<>();
    int freeSpace = 0;

    // Skip the OS partition
    for (int i = 1; i < myOS.partitionTable.size(); i++) {
      Partition partition = myOS.partitionTable.get(i);

      if (!partition.isFree) {
        // Move the content of the partition to the new base address
        if (freeSpace > 0) {
          for (int j = 0; j < partition.size; j++) {
            int oldAddress = partition.baseAddress + j;
            int newAddress = partition.baseAddress - freeSpace + j;
            char content = myPC.RAM[oldAddress / myPC.RAMSizeInBank][oldAddress % myPC.RAMSizeInBank];
            myPC.RAM[newAddress / myPC.RAMSizeInBank][newAddress % myPC.RAMSizeInBank] = content;
          }
          // Update the base address of the partition
          partition.baseAddress -= freeSpace;
        }
      } else {
        // Add the free space to the total
        freeSpace += partition.size;
        // partitionsToRemove.add(partition);
        myOS.partitionTable.remove(partition);
        // Relocate the index to the next partition
        i--;
      }
    }

    //Remove the free partitions
    myOS.partitionTable.removeAll(partitionsToRemove);
    
    // Create a new partition with the free space
    if (freeSpace > 0) {
      int lastPartitionIndex = myOS.partitionTable.size() - 1;
      int lastPartitionBA = myOS.partitionTable.get(lastPartitionIndex).baseAddress;
      int lastPartitionSize = myOS.partitionTable.get(lastPartitionIndex).size;
      int newPartitionAddress = lastPartitionBA + lastPartitionSize;
      Partition newPartition = new Partition(newPartitionAddress, freeSpace);
      myOS.partitionTable.add(newPartition);  
    }
    sim.addToLog("  >Compact: Compacted memory. Starting Process Scheduler");
    sim.addToLog(myOS.partitionTable.toString());

    myOS.startKernelProcess("scheduler");
    this.state = STATE.READY;
  }
}
