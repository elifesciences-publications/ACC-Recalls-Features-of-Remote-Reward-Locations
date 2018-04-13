
% clear
addpath(genpath('E:\MClust-4.3\'));
addpath(genpath('E:\DataHigh1.1\DataHigh1.1\'));
%%
folderPath = 'E:\New folder\P1958_25p\'; 

data = CreateAllData(folderPath, []);
data.data(data.dataIndex, :) = smoother(data.data(data.dataIndex, :), 150, 1);
choice = [data.trInfo.choice];

%%
[timestamps, binDataAll, binLoc, trial] = BinData(data, 50, 0);
binLoc = MapToRect(binLoc, trial, data);

%%
posTrial = data.trials(choice(data.trials) == 1);
negTrial = data.trials(choice(data.trials) == 0);
minNum = min(numel(posTrial), numel(negTrial));

bestErrorForNumCell = [0.8614    0.6986    0.5496    0.4474    0.3493    0.2964    0.2338    0.2029];
bestCells = [13     5    46     8     6    40     3    49    29    44    42    52    16     9     1    27     4    19    15    31];

for numCell = 1:20
    
    bestNextCell = -1;
    bestErrorForNumCell(numCell) = inf;
    
    for cellIndex = 1:size(binDataAll, 1)
        if(ismember(cellIndex, bestCells))
            continue
        end

        candidateSet = [bestCells cellIndex];       
        binData = binDataAll(candidateSet, :);

        for it = 1:5
            selectedPos = randsample(posTrial, minNum);
            selectedNeg = randsample(negTrial, minNum);

            AllSelected = [selectedPos selectedNeg];

            r = rand(1, numel(AllSelected));
            trainTrials = AllSelected(r <= 0.75);
            testTrials  = AllSelected(r >  0.75);           

            trainIndices = ismember(trial, trainTrials);
            testIndices  = ismember(trial, testTrials);

            train = binData(:, trainIndices);
            loc_t = binLoc(:, trainIndices);

            indices = randperm(length(loc_t));
            train = train(:, indices);
            loc_t = loc_t(:, indices);

            valid = binData(:, testIndices);
            loc_v = binLoc(:, testIndices);

            trial_t = trial(trainIndices);
            trial_v = trial(testIndices);

            timestamps_t = timestamps(trainIndices);
            timestamps_v = timestamps(testIndices);

            save('data', 'train', 'loc_t', 'valid', 'loc_v');
            system('python C:\Users\a.mashhoori\Desktop\Proj\Scripts\main.py');
            a = load('data_out');
            res = a.res';               

            err(it) = sum(sum((loc_v - res) .^ 2)) / numel(loc_v);
            fprintf('The error for it %d is %f \n', it, err(it));
        end

        error = mean(err);

        if( error < bestErrorForNumCell(numCell) )
            bestNextCell = cellIndex;
            bestErrorForNumCell(numCell) = error;
        end    
    end
    
    bestCells = [bestCells bestNextCell];
    
end
return 


%  26     4    14    24     1    30    23    33    18    38    36    31     6    39     2     5    32    20    29    19
% 1.0375    0.8386    0.5976    0.4954    0.4008    0.3343    0.2761    0.2032    0.1522    0.1292    0.1573    0.1372    0.1125    0.1068    0.1049    0.1074 0.1045    0.1052    0.1057    0.0851

% 22    18    26     4    29    23     6     1    31    17    24    21    16    30    27    33     2    14    20    36


