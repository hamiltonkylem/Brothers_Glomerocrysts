<<<<<<< HEAD
%% Cluster analysis script for creating glomerocryst groups


clear
clc
close all

input_file = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\Matlab script exports\all samples.csv";
table1 = readtable(input_file, VariableNamingRule="preserve");

id = strcat(table1.Sample, ' ', table1.Name);
table1b = addvars(table1, id, 'After','Name');


%% HCA individual samples

table2 = table1(:, setdiff(1:size(table1, 2), [3, 4, 10]));
[table3, remove_idx] = rmmissing(table2);

sample_names= table3.Sample;
list_names = unique(sample_names);
n_samples = length(list_names);

for i = 1:n_samples

    %Data
    table4 = table3(strcmp(table3.Sample, list_names(i)), : );
    labels = cellstr(table4.Name);   
    X = table2array(table4(:, 3:end));
    
    %calculation
    tree = linkage(X,"average");
    D = pdist(X);
    leafOrder = optimalleaforder(tree,D);
    
    %plot
    figure
    dendrogram(tree,0, Reorder=leafOrder, Labels=labels );
    title(sprintf('Hierarchical cluster analysis: %s', list_names{i}))
    ylabel('Distance')
    xlabel('Leafs (glomerocrysts)')
end

%% HCA all samples

table2 = table1b(:, setdiff(1:size(table1b, 2), [4, 5, 11]));
[table3, remove_idx] = rmmissing(table2);

%Data
labels = cellstr(table3.id);   
X = table2array(table3(:, 4:end));

%calculation
tree = linkage(X,"average");
D = pdist(X);
leafOrder = optimalleaforder(tree,D);

%plot
figure
dendrogram(tree, 0, Reorder=leafOrder, Labels=labels );
xtickangle(90) % Tilts them nicely at 45 degrees
set(gca, 'Position', [0.1, 0.35, 0.85, 0.55]) % Lifts plot up to give 25% space at bottom
title(sprintf('Hierarchical cluster analysis: %s', 'all'))
ylabel('Distance')
xlabel('Leafs (glomerocrysts)')
set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');

%% Gemini 3 trial

%% HCA all samples
table2 = table1b(:, setdiff(1:size(table1b, 2), [4, 5, 11]));
[table3, remove_idx] = rmmissing(table2);

% Data
labels = cellstr(table3.id);   
X = table2array(table3(:, 4:end));

% Calculation
tree = linkage(X, "average");
D = pdist(X);
leafOrder = optimalleaforder(tree, D);

% --- NEW: User Input for Threshold ---
prompt = {'Enter the y-axis distance threshold to define clusters:'};
dlgtitle = 'Cluster Threshold';
dims = [1 50];
definput = {'0.5'}; % Default threshold value, change as needed
user_input = inputdlg(prompt, dlgtitle, dims, definput);

% If user cancels, default to 0.5 to prevent errors
if isempty(user_input)
    threshold = 0.5;
else
    threshold = str2double(user_input{1});
end

% --- NEW: Generate Cluster Memberships ---
% 'criterion','distance' cuts the tree horizontally at the threshold height
cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', threshold);

% Plot
figure
% Show the full tree (0)
dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
xtickangle(90)
set(gca, 'Position', [0.10, 0.30, 0.85, 0.60]) % Adjust space for long labels

title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', 'all', threshold))
ylabel('Distance')
xlabel('Leafs (glomerocrysts)')
set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');

% --- NEW: Draw Threshold Line on Plot ---
hold on
xl = xlim;
line(xl, [threshold, threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
hold off

% --- NEW: Export Results to CSV ---
% Add the cluster assignments as a new column to the table
output_table = table3;
output_table.ClusterGroup = cluster_assignments;

% Define export path (saving to your Desktop next to the original)
output_file = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\all_samples_with_clusters.csv";
writetable(output_table, output_file);

fprintf('Success! Cluster memberships saved to:\n%s\n', output_file);

%% Gemini 3 trial.2

%%
%% HCA individual samples
table2 = table1(:, setdiff(1:size(table1, 2), [3, 4, 10]));
[table3, remove_idx] = rmmissing(table2);
sample_names = table3.Sample;
list_names = unique(sample_names);
n_samples = length(list_names);

% --- NEW: Multi-Prompt User Input for Individual Thresholds ---
% This creates a single window asking for thresholds for all samples at once
prompt = cell(1, n_samples);
definput = cell(1, n_samples);
for i = 1:n_samples
    prompt{i} = sprintf('Threshold for %s:', list_names{i});
    definput{i} = '0.5'; % Default value for each sample
end
dims = [1 50];
user_inputs = inputdlg(prompt, 'Individual Sample Thresholds', dims, definput);

% Fallback if user cancels the window
if isempty(user_inputs)
    thresholds = repmat(0.5, 1, n_samples);
else
    thresholds = str2double(user_inputs);
end

% --- Loop through each sample ---
for i = 1:n_samples
    % Data
    table4 = table3(strcmp(table3.Sample, list_names(i)), : );
    labels = cellstr(table4.Name);   
    X = table2array(table4(:, 3:end));
    
    % Calculation
    tree = linkage(X, "average");
    D = pdist(X);
    leafOrder = optimalleaforder(tree, D);
    
    % Current threshold for this specific sample
    current_threshold = thresholds(i);
    
    % --- NEW: Generate Cluster Memberships ---
    cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', current_threshold);
    
    % Plot
    figure
    % Using '0' here as well to ensure full tree visibility per sample
    dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
    xtickangle(90) % Force labels vertical
    set(gca, 'Position', [0.10, 0.35, 0.85, 0.55]) % Give vertical labels room
    
    title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', list_names{i}, current_threshold))
    ylabel('Distance')
    xlabel('Leafs (glomerocrysts)')
    set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');
    
    % --- NEW: Draw Threshold Line ---
    hold on
    xl = xlim;
    line(xl, [current_threshold, current_threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    hold off
    
    % --- NEW: Export Individual Sample Results ---
    output_table_individual = table4;
    output_table_individual.ClusterGroup = cluster_assignments;
    
    % Creates a unique filename for each sample (e.g., "Sample_A_clusters.csv")
    safe_sample_name = regexprep(list_names{i}, '[^\w\-_]', '_'); % Removes spaces/special chars for safe saving
    output_file_individual = sprintf("C:\\Users\\n12108359\\OneDrive - Queensland University of Technology\\Desktop\\%s_clusters.csv", safe_sample_name);
    
    writetable(output_table_individual, output_file_individual);
    fprintf('Saved cluster results for %s to desktop.\n', list_names{i});
end

%% Gemini 3 trial 3

%%
clear
clc
close all

% Input File Path
input_file = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\Matlab script exports\all samples.csv";

% --- CRITICAL: Make sure this section is at the very top! ---
output_folder = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\Matlab script exports";

% Create the folder if it doesn't exist yet
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Read and prepare data
table1 = readtable(input_file, VariableNamingRule="preserve");
id = strcat(table1.Sample, ' ', table1.Name);
table1b = addvars(table1, id, 'After','Name');

%% ========================================================================
%% HCA individual samples
%% ========================================================================
table2 = table1(:, setdiff(1:size(table1, 2), [3, 4, 10]));
[table3, remove_idx] = rmmissing(table2);
sample_names = table3.Sample;
list_names = unique(sample_names);
n_samples = length(list_names);

% Multi-Prompt User Input for Individual Thresholds
prompt = cell(1, n_samples);
definput = cell(1, n_samples);
for i = 1:n_samples
    prompt{i} = sprintf('Threshold for %s:', list_names{i});
    definput{i} = '0.5'; 
end
dims = [1 50];
user_inputs = inputdlg(prompt, 'Individual Sample Thresholds', dims, definput);

if isempty(user_inputs)
    thresholds = repmat(0.5, 1, n_samples);
else
    thresholds = str2double(user_inputs);
end

% Loop through each sample
for i = 1:n_samples
    % Data
    table4 = table3(strcmp(table3.Sample, list_names(i)), : );
    labels = cellstr(table4.Name);   
    X = table2array(table4(:, 3:end));
    
    % Calculation
    tree = linkage(X, "average");
    D = pdist(X);
    leafOrder = optimalleaforder(tree, D);
    
    current_threshold = thresholds(i);
    
    % Generate Cluster Memberships
    cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', current_threshold);
    
    % Plot
    figure
    dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
    xtickangle(90) 
    set(gca, 'Position', [0.10, 0.35, 0.85, 0.55]) 
    
    title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', list_names{i}, current_threshold))
    ylabel('Distance')
    xlabel('Leafs (glomerocrysts)')
    set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');
    
    % Draw Threshold Line
    hold on
    xl = xlim;
    line(xl, [current_threshold, current_threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    hold off
    
    % Export Individual Sample Results
    output_table_individual = table4;
    output_table_individual.ClusterGroup = cluster_assignments;
    
    safe_sample_name = regexprep(list_names{i}, '[^\w\-_]', '_'); 
    
    % --- Updated Export Path ---
    output_file_individual = fullfile(output_folder, sprintf("%s_clusters.csv", safe_sample_name));
    
    writetable(output_table_individual, output_file_individual);
    fprintf('Saved cluster results for %s to export folder.\n', list_names{i});
end

%% ========================================================================
%% HCA all samples
%% ========================================================================
table2 = table1b(:, setdiff(1:size(table1b, 2), [4, 5, 11]));
[table3, remove_idx] = rmmissing(table2);

% Data
labels = cellstr(table3.id);   
X = table2array(table3(:, 4:end));

% Calculation
tree = linkage(X, "average");
D = pdist(X);
leafOrder = optimalleaforder(tree, D);

% User Input for Threshold
prompt = {'Enter the y-axis distance threshold for ALL samples combined:'};
dlgtitle = 'Combined Cluster Threshold';
dims = [1 50];
definput = {'0.5'}; 
user_input = inputdlg(prompt, dlgtitle, dims, definput);

if isempty(user_input)
    threshold = 0.5;
else
    threshold = str2double(user_input{1});
end

% Generate Cluster Memberships
cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', threshold);

% Plot
figure
dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
xtickangle(90)
set(gca, 'Position', [0.10, 0.35, 0.85, 0.55]) 

title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', 'all', threshold))
ylabel('Distance')
xlabel('Leafs (glomerocrysts)')
set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');

% Draw Threshold Line
hold on
xl = xlim;
line(xl, [threshold, threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
hold off

% Export Combined Results
output_table = table3;
output_table.ClusterGroup = cluster_assignments;

% --- Updated Export Path ---
output_file_combined = fullfile(output_folder, "all_samples_with_clusters.csv");

writetable(output_table, output_file_combined);
=======
%% Cluster analysis script for creating glomerocryst groups


clear
clc
close all

input_file = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\Matlab script exports\all samples.csv";
table1 = readtable(input_file, VariableNamingRule="preserve");

id = strcat(table1.Sample, ' ', table1.Name);
table1b = addvars(table1, id, 'After','Name');


%% HCA individual samples

table2 = table1(:, setdiff(1:size(table1, 2), [3, 4, 10]));
[table3, remove_idx] = rmmissing(table2);

sample_names= table3.Sample;
list_names = unique(sample_names);
n_samples = length(list_names);

for i = 1:n_samples

    %Data
    table4 = table3(strcmp(table3.Sample, list_names(i)), : );
    labels = cellstr(table4.Name);   
    X = table2array(table4(:, 3:end));
    
    %calculation
    tree = linkage(X,"average");
    D = pdist(X);
    leafOrder = optimalleaforder(tree,D);
    
    %plot
    figure
    dendrogram(tree,0, Reorder=leafOrder, Labels=labels );
    title(sprintf('Hierarchical cluster analysis: %s', list_names{i}))
    ylabel('Distance')
    xlabel('Leafs (glomerocrysts)')
end

%% HCA all samples

table2 = table1b(:, setdiff(1:size(table1b, 2), [4, 5, 11]));
[table3, remove_idx] = rmmissing(table2);

%Data
labels = cellstr(table3.id);   
X = table2array(table3(:, 4:end));

%calculation
tree = linkage(X,"average");
D = pdist(X);
leafOrder = optimalleaforder(tree,D);

%plot
figure
dendrogram(tree, 0, Reorder=leafOrder, Labels=labels );
xtickangle(90) % Tilts them nicely at 45 degrees
set(gca, 'Position', [0.1, 0.35, 0.85, 0.55]) % Lifts plot up to give 25% space at bottom
title(sprintf('Hierarchical cluster analysis: %s', 'all'))
ylabel('Distance')
xlabel('Leafs (glomerocrysts)')
set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');

%% Gemini 3 trial

%% HCA all samples
table2 = table1b(:, setdiff(1:size(table1b, 2), [4, 5, 11]));
[table3, remove_idx] = rmmissing(table2);

% Data
labels = cellstr(table3.id);   
X = table2array(table3(:, 4:end));

% Calculation
tree = linkage(X, "average");
D = pdist(X);
leafOrder = optimalleaforder(tree, D);

% --- NEW: User Input for Threshold ---
prompt = {'Enter the y-axis distance threshold to define clusters:'};
dlgtitle = 'Cluster Threshold';
dims = [1 50];
definput = {'0.5'}; % Default threshold value, change as needed
user_input = inputdlg(prompt, dlgtitle, dims, definput);

% If user cancels, default to 0.5 to prevent errors
if isempty(user_input)
    threshold = 0.5;
else
    threshold = str2double(user_input{1});
end

% --- NEW: Generate Cluster Memberships ---
% 'criterion','distance' cuts the tree horizontally at the threshold height
cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', threshold);

% Plot
figure
% Show the full tree (0)
dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
xtickangle(90)
set(gca, 'Position', [0.10, 0.30, 0.85, 0.60]) % Adjust space for long labels

title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', 'all', threshold))
ylabel('Distance')
xlabel('Leafs (glomerocrysts)')
set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');

% --- NEW: Draw Threshold Line on Plot ---
hold on
xl = xlim;
line(xl, [threshold, threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
hold off

% --- NEW: Export Results to CSV ---
% Add the cluster assignments as a new column to the table
output_table = table3;
output_table.ClusterGroup = cluster_assignments;

% Define export path (saving to your Desktop next to the original)
output_file = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\all_samples_with_clusters.csv";
writetable(output_table, output_file);

fprintf('Success! Cluster memberships saved to:\n%s\n', output_file);

%% Gemini 3 trial.2

%%
%% HCA individual samples
table2 = table1(:, setdiff(1:size(table1, 2), [3, 4, 10]));
[table3, remove_idx] = rmmissing(table2);
sample_names = table3.Sample;
list_names = unique(sample_names);
n_samples = length(list_names);

% --- NEW: Multi-Prompt User Input for Individual Thresholds ---
% This creates a single window asking for thresholds for all samples at once
prompt = cell(1, n_samples);
definput = cell(1, n_samples);
for i = 1:n_samples
    prompt{i} = sprintf('Threshold for %s:', list_names{i});
    definput{i} = '0.5'; % Default value for each sample
end
dims = [1 50];
user_inputs = inputdlg(prompt, 'Individual Sample Thresholds', dims, definput);

% Fallback if user cancels the window
if isempty(user_inputs)
    thresholds = repmat(0.5, 1, n_samples);
else
    thresholds = str2double(user_inputs);
end

% --- Loop through each sample ---
for i = 1:n_samples
    % Data
    table4 = table3(strcmp(table3.Sample, list_names(i)), : );
    labels = cellstr(table4.Name);   
    X = table2array(table4(:, 3:end));
    
    % Calculation
    tree = linkage(X, "average");
    D = pdist(X);
    leafOrder = optimalleaforder(tree, D);
    
    % Current threshold for this specific sample
    current_threshold = thresholds(i);
    
    % --- NEW: Generate Cluster Memberships ---
    cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', current_threshold);
    
    % Plot
    figure
    % Using '0' here as well to ensure full tree visibility per sample
    dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
    xtickangle(90) % Force labels vertical
    set(gca, 'Position', [0.10, 0.35, 0.85, 0.55]) % Give vertical labels room
    
    title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', list_names{i}, current_threshold))
    ylabel('Distance')
    xlabel('Leafs (glomerocrysts)')
    set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');
    
    % --- NEW: Draw Threshold Line ---
    hold on
    xl = xlim;
    line(xl, [current_threshold, current_threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    hold off
    
    % --- NEW: Export Individual Sample Results ---
    output_table_individual = table4;
    output_table_individual.ClusterGroup = cluster_assignments;
    
    % Creates a unique filename for each sample (e.g., "Sample_A_clusters.csv")
    safe_sample_name = regexprep(list_names{i}, '[^\w\-_]', '_'); % Removes spaces/special chars for safe saving
    output_file_individual = sprintf("C:\\Users\\n12108359\\OneDrive - Queensland University of Technology\\Desktop\\%s_clusters.csv", safe_sample_name);
    
    writetable(output_table_individual, output_file_individual);
    fprintf('Saved cluster results for %s to desktop.\n', list_names{i});
end

%% Gemini 3 trial 3

%%
clear
clc
close all

% Input File Path
input_file = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\Matlab script exports\all samples.csv";

% --- CRITICAL: Make sure this section is at the very top! ---
output_folder = "C:\Users\n12108359\OneDrive - Queensland University of Technology\Desktop\Matlab script exports";

% Create the folder if it doesn't exist yet
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Read and prepare data
table1 = readtable(input_file, VariableNamingRule="preserve");
id = strcat(table1.Sample, ' ', table1.Name);
table1b = addvars(table1, id, 'After','Name');

%% ========================================================================
%% HCA individual samples
%% ========================================================================
table2 = table1(:, setdiff(1:size(table1, 2), [3, 4, 10]));
[table3, remove_idx] = rmmissing(table2);
sample_names = table3.Sample;
list_names = unique(sample_names);
n_samples = length(list_names);

% Multi-Prompt User Input for Individual Thresholds
prompt = cell(1, n_samples);
definput = cell(1, n_samples);
for i = 1:n_samples
    prompt{i} = sprintf('Threshold for %s:', list_names{i});
    definput{i} = '0.5'; 
end
dims = [1 50];
user_inputs = inputdlg(prompt, 'Individual Sample Thresholds', dims, definput);

if isempty(user_inputs)
    thresholds = repmat(0.5, 1, n_samples);
else
    thresholds = str2double(user_inputs);
end

% Loop through each sample
for i = 1:n_samples
    % Data
    table4 = table3(strcmp(table3.Sample, list_names(i)), : );
    labels = cellstr(table4.Name);   
    X = table2array(table4(:, 3:end));
    
    % Calculation
    tree = linkage(X, "average");
    D = pdist(X);
    leafOrder = optimalleaforder(tree, D);
    
    current_threshold = thresholds(i);
    
    % Generate Cluster Memberships
    cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', current_threshold);
    
    % Plot
    figure
    dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
    xtickangle(90) 
    set(gca, 'Position', [0.10, 0.35, 0.85, 0.55]) 
    
    title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', list_names{i}, current_threshold))
    ylabel('Distance')
    xlabel('Leafs (glomerocrysts)')
    set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');
    
    % Draw Threshold Line
    hold on
    xl = xlim;
    line(xl, [current_threshold, current_threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
    hold off
    
    % Export Individual Sample Results
    output_table_individual = table4;
    output_table_individual.ClusterGroup = cluster_assignments;
    
    safe_sample_name = regexprep(list_names{i}, '[^\w\-_]', '_'); 
    
    % --- Updated Export Path ---
    output_file_individual = fullfile(output_folder, sprintf("%s_clusters.csv", safe_sample_name));
    
    writetable(output_table_individual, output_file_individual);
    fprintf('Saved cluster results for %s to export folder.\n', list_names{i});
end

%% ========================================================================
%% HCA all samples
%% ========================================================================
table2 = table1b(:, setdiff(1:size(table1b, 2), [4, 5, 11]));
[table3, remove_idx] = rmmissing(table2);

% Data
labels = cellstr(table3.id);   
X = table2array(table3(:, 4:end));

% Calculation
tree = linkage(X, "average");
D = pdist(X);
leafOrder = optimalleaforder(tree, D);

% User Input for Threshold
prompt = {'Enter the y-axis distance threshold for ALL samples combined:'};
dlgtitle = 'Combined Cluster Threshold';
dims = [1 50];
definput = {'0.5'}; 
user_input = inputdlg(prompt, dlgtitle, dims, definput);

if isempty(user_input)
    threshold = 0.5;
else
    threshold = str2double(user_input{1});
end

% Generate Cluster Memberships
cluster_assignments = cluster(tree, 'Criterion', 'distance', 'Cutoff', threshold);

% Plot
figure
dendrogram(tree, 0, Reorder=leafOrder, Labels=labels); 
xtickangle(90)
set(gca, 'Position', [0.10, 0.35, 0.85, 0.55]) 

title(sprintf('Hierarchical cluster analysis: %s (Threshold = %g)', 'all', threshold))
ylabel('Distance')
xlabel('Leafs (glomerocrysts)')
set(findall(gca, 'Type', 'text'), 'Interpreter', 'none');

% Draw Threshold Line
hold on
xl = xlim;
line(xl, [threshold, threshold], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5);
hold off

% Export Combined Results
output_table = table3;
output_table.ClusterGroup = cluster_assignments;

% --- Updated Export Path ---
output_file_combined = fullfile(output_folder, "all_samples_with_clusters.csv");

writetable(output_table, output_file_combined);
>>>>>>> 1c7b44c49ed87ace8d91d96747fff8c5e694bbbc
fprintf('Success! Combined cluster memberships saved to export folder.\n');