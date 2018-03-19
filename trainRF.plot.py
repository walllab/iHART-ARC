#!/usr/bin/env python
import glob
import pandas as pd
import matplotlib as mpl
mpl.use('agg')
import matplotlib.pyplot as plt
from sklearn.metrics import precision_recall_curve, roc_curve
from sklearn.metrics import roc_auc_score, f1_score, precision_score, recall_score


def init_figure(setAxisRange=True, figSize=None):
    fig, ax = plt.subplots(dpi=600, figsize=figSize)

    if setAxisRange:
        plt.axis([-0.01, 1.01, -0.01, 1.01])

    ax.xaxis.set_minor_locator(mpl.ticker.AutoMinorLocator()) # set minor ticks
    ax.yaxis.set_minor_locator(mpl.ticker.AutoMinorLocator())

    ax.grid(which='major', ls='solid',  alpha=0.5)  # show grid on both axes
    ax.grid(which='minor', ls='dotted', alpha=0.4)

    ax.spines['right'].set_visible(False)
    ax.spines['top'  ].set_visible(False)

    return fig, ax


def draw_boxplots(data):
    bp = plt.boxplot(data, patch_artist=True)
    for box in bp["boxes"]:
        box.set(color="#7570b3")     # outline color
        box.set(facecolor="#1b9e77") # fill color
        for w in bp["whiskers"]:
            w.set(color="#7570b3", linewidth=1)
        for c in bp["caps"]:
            c.set(color="#7570b3", linewidth=1)
        for m in bp["medians"]:
            m.set(color="#b2df8a", linewidth=2)
        for f in bp["fliers"]:
            f.set(marker="+", markeredgecolor="#e7298a")

    return bp


def draw_pr_curve():
    fig, ax = init_figure()
    idx = 1
    for f in glob.glob("./fold*.tsv"):
        data = pd.read_csv(f, sep="\t")
        precision, recall, thr = precision_recall_curve(data["y"], data["prob"])
        plt.plot(recall, precision, label="Fold %02d"%(idx))
        idx += 1

    plt.xlabel("Recall")
    plt.ylabel("Precision")
    plt.legend(loc="lower left")
    plt.savefig("train-pr.png")


def draw_roc_curve():
    fig, ax = init_figure()
    idx = 1
    for f in glob.glob("./fold*.tsv"):
        data = pd.read_csv(f, sep="\t")
        fpr, tpr, thr = roc_curve(data["y"], data["prob"])
        plt.plot(fpr, tpr, label="Fold %02d"%(idx))
        idx += 1

    plt.xlabel("False Positive rate (1-Specificity)")
    plt.ylabel("True Positive rate (Sensitivity)")
    plt.legend(loc="lower right")
    plt.savefig("train-roc.png")


def draw_auc_boxplot():
    fig, ax = init_figure(setAxisRange=False)
    auc = []
    for f in glob.glob("./fold*.tsv"):
        data = pd.read_csv(f, sep="\t")
        auc.append(roc_auc_score(data["y"], data["prob"]))

    draw_boxplots(auc)
    plt.setp(ax.get_xticklabels(), visible=False) # hide xtick label here
    plt.ylabel("ROC_AUC", fontsize=12)
    plt.savefig("train-auc.png")


def draw_cutoff_boxplots(data, ylab, fname):
    #fig, ax = plt.subplots(dpi=600, figsize=(15, 8))
    fig, ax = init_figure(setAxisRange=False, figSize=(15,8))
    ax.xaxis.grid(b=False, which='minor')     # turn minor grid off for xaxis
    ax.xaxis.set_tick_params(which='minor', bottom='off')

    draw_boxplots(data)
    plt.xticks(range(1,len(data)+1), [".%2d"%(x) for x in range(10, 80, 2)])  # set customm xticks from .10 to .78
    plt.xlabel("Score Value Cutoff", fontsize=15)
    plt.ylabel(ylab, fontsize=15)
    plt.savefig("train-"+fname+"-boxplots.png")


def get_scores_per_cutoff():
    cutoffs = range(10, 80, 2)  # actual cutoff = value/100
    f1 = dict()
    pr = dict()
    re = dict()

    # save 10 (fold) scores per cutoff
    for c in cutoffs:
        f1[c] = []
        pr[c] = []
        re[c] = []
        for f in glob.glob("./fold*.tsv"):
            data = pd.read_csv(f, sep="\t")
            newProb = [1 if p >= float(c)/100 else 0 for p in data["prob"]]
            f1[c].append(f1_score       (data["y"], newProb))
            pr[c].append(precision_score(data["y"], newProb))
            re[c].append(recall_score   (data["y"], newProb))

    # Get sorted array from dict
    f1List = [ f1[c] for c in cutoffs ]
    prList = [ pr[c] for c in cutoffs ]
    reList = [ re[c] for c in cutoffs ]

    return f1List, prList, reList

def main():
    # make training figures if there are "fold*.tsv" files in the current directory
    if not glob.glob("./fold*.tsv"):
        print "Cannot find fold*.tsv files in the current directory"
        sys.exit(1)

    draw_pr_curve()
    draw_roc_curve()
    draw_auc_boxplot()

    f1, pr, re = get_scores_per_cutoff()
    draw_cutoff_boxplots(f1, ylab="F1 Score in 10 Fold CV",  fname="f1")
    draw_cutoff_boxplots(pr, ylab="Precision in 10 Fold CV", fname="precision")
    draw_cutoff_boxplots(re, ylab="Recall in 10 Fold CV",    fname="recall")


if __name__ == "__main__":
    main()
