function [G,mergedGrains] = CompareBoundaryAndMean(G,grains,Mistol,twins)
%Compares merged twinned boundaries with mean misorientation twins
    ntwins=length(twins);
    mineral=grains.mineral;
    gB=grains.boundary;
    gB_mineral = gB(mineral,mineral);
    twinBoundary={};
    for i=1:ntwins    
        isTwinning = angle(gB_mineral.misorientation,twins{i}) < Mistol;
        twinBoundary{i} = gB_mineral(isTwinning);
    end
    combinedTwinBoundary=[twinBoundary{:}];
    [mergedGrains,parentId] = merge(grains,combinedTwinBoundary);

    %Combines boundary from both methods (need to reinitialize the twin
    %type
    G.Edges.combineBoundary=zeros(length(G.Edges.pairs),1,'logical')
    for i=1:length(mergedGrains) 
        grainid = grains(parentId == mergedGrains(i).id).id;
        if length(grainid)>1
            %initialize
            combine1=zeros(length(G.Edges.pairs(:,1)),1,'logical');
            combine2=zeros(length(G.Edges.pairs(:,1)),1,'logical');
            
            %for each merged grain, identify all edges that have the grains
            for j=1:length(grainid)
                combine1(find(grainid(j)==G.Edges.pairs(:,1)))=true;
                combine2(find(grainid(j)==G.Edges.pairs(:,2)))=true;
            end
            %Sum the pairs to see which edges are in the merged
            %grains. This creates a combine that is based on boundary
            G.Edges.combineBoundary((combine1+combine2)==2)=true;
            %%%%%%Update boundary type here and remove from
            %%%%%%InitizeGraph
        end
        group(grainid)=i;
    end
    
    %Map the merged grains to pairs
%     G.Edges.combineMerge=zeros(length(G.Edges.pairs),1);
%     G.Edges.groupMerge=zeros(length(G.Edges.pairs),1);
%     for i=1:length(G.Edges.pairs)
%           nodes=G.Edges.pairs(i,:);
%           if all(ismember(nodes,grains(combine).id))
%              G.Edges.combineMerge(i)=true;
%              G.Edges.groupMerge(i)=group(nodes(1));
%           end
%     end
       
    figure; 
    plot(grains,grains.meanOrientation,'Micronbar','off')
    hold on 
    colors=hsv(ntwins);
    for i=1:ntwins
        plot(twinBoundary{i},'linecolor',colors(i,:),'linewidth',2);
    end
    plot(mergedGrains.boundary,'linecolor','k','linewidth',2.5,'linestyle','-',...
        'displayName','merged grains')
    p=plot(G,'XData',G.Nodes.centroids(:,1),...
            'YData',G.Nodes.centroids(:,2));
        hold off
        p.Marker='s';p.NodeColor='k';p.MarkerSize=3;p.EdgeColor='k';
    hold off

end

