# Increment Revision Build Task

A batch file to be run before a program build in a C# application that parses the assembly information file and increments the revision number for the assembly file version. It is essentially a find-and-replace function on a file by a batch script.

## Usage

Add a pre-build event that calls this batch file, such as in the example below in which the batch file is in a separate directory and it is only executed on Release builds, not on Debug builds.

    <PropertyGroup>
      <PreBuildEvent>IF $(Configuration) == Release CALL $(SolutionDir)..\increment-revision-build-task\IncrementRevision.bat $(ProjectDir)Properties</PreBuildEvent>
    </PropertyGroup>

## Known issues

Because the "FOR /F" batch command removes leading spaces from tokens and skips over empty lines in files, all indents and empty lines will be removed as a result. This is unfortunate, but finding a workaround has been difficult considering the limitations.